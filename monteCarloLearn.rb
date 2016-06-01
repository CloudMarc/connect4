# Brute force Monte Carlo learning
require 'redis'
require_relative 'connect4'


class MonteCarloLearning
  # See https://github.com/lukasvermeer/connectfourservice
  def initialize
    @redis = Redis.new
    @test_players = ['X','O']
    @test_ncolumns = 7
    @test_nrows = 6
    @test_board = Connect4Board.new(@test_ncolumns, @test_nrows,
    @test_players.first, @test_players.last)
  end

  def train
    xwins = 0
    owins = 0
    player = @test_players.last
    loop do
      @test_board = Connect4Board.new(@test_ncolumns, @test_nrows,
                               @test_players.first, @test_players.last)
      moves = []
      200.times  do
        if player == @test_players.last
          player = @test_players.first
        else
          player = @test_players.last
        end
        column = rand(@test_ncolumns)
        unless @test_board.check_legal_move(player, column)
          next
        end
        flat_board = @test_board.get_flattened_board
        if player==@test_players.first
          key = flat_board.join('')
          key.gsub!('*','.')
          #puts key.inspect
          zwkey = 'win::results::'+player+'::'+key
          zlkey = 'lose::results::'+player+'::'+key
          best_score = -100.0
          best_col = -1
          best_cols = []
          (0..(@test_ncolumns-1)).each { |i|
            wins = @redis.zscore(zwkey, i).to_i
            lose = @redis.zscore(zlkey, i).to_i
            db = 10.0*(Math.log10( (wins+1.0)/(lose+1.0) ) )
            if db == best_score
              best_cols.push(i)
            end
            if db > best_score
              best_score = db
              best_col = i
            end
            #puts i.inspect + ' ' + db.inspect 
          }
          if best_score == 0.0
            column = best_cols.sample
          else
            column = best_col
          end
          if column.nil?
            column = best_col
          end
          if moves.length < 5
            column = rand(@test_ncolumns)
          end
          #puts column.inspect + ' ' + best_score.inspect + ' ' + best_col.inspect
        end
        #puts "column = " + column.inspect
        move = [player, column, flat_board]
        moves.push(move)
        @test_board.process_move(player, column)
        #@test_board.display()
        result = @test_board.check_winner()
        if @test_players.include?(result)
          #@test_board.display()
          if result==@test_players.first
            xwins = @redis.incr("xwins"+(Time.now.to_f/3600).round(0).to_s)
          else
            if result==@test_players.last
              owins = @redis.incr("owins"+(Time.now.to_f/3600).round(0).to_s)
            end
          end
          moves.each { |move|
            move_player = move.shift
            move_col = move.shift
            flat_board = move.shift
            key = flat_board.join('')
            key.gsub!('*','.')
            if move_player==result # winner
              @redis.zincrby('win::results::'+move_player+'::'+key, 1.0, move_col)
            else
              @redis.zincrby('lose::results::'+move_player+'::'+key, 1.0, move_col)
            end
          }
          break
        end
      end
      if rand(100)==1
        xwins = @redis.get('xwins'+(Time.now.to_f/3600.0).round(0).to_s).to_f
        owins = @redis.get('owins'+(Time.now.to_f/3600.0).round(0).to_s).to_f
        tot = xwins + owins
        pct = (100.0*(xwins/tot)).round(2)
        top = @redis.zrevrange("winpct::", 0, 1, :with_scores => true).first
        pct0 = top.last.to_f
        #puts pct0.inspect + ' ' + pct.inspect  + ' ' + top.inspect
        if (pct-pct0).abs > 0.02
          @redis.zadd("winpct::", pct, tot)
        end
        #puts "Player 1 wins:  " + xwins.inspect
        #puts "Player 2 wins:  " + owins.inspect
        res = @redis.zrange("winpct::", 0, -1, :with_scores => true)
        res.each { |x|
          #puts x.inspect
          pct = x.last.to_f
          cnt = x.first.to_i
          if pct.nil? or pct.to_f == 0.0
            next
          end
          if cnt > 1000
            puts cnt.inspect + " " + pct.inspect
          end
        }
        sleep 1
      end
    end
  end

end


monte = MonteCarloLearning.new
monte.train
