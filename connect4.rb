require 'logger'

"""
The task is to write an implementation of the game Connect-4 (http://en.wikipedia.org/wiki/Connect_Four).

In Connect-4, there are two players, and each of the players take turns trying to get four of their game pieces in a column.

Write a functional subset of the code for the game board, game pieces, and player state. Your code should include functions to place a piece into the game board and check if one of the players has won the game. Your code should simulate the turns taken by players (in other words, you do NOT have to rowlect actual input from players, so you should not build UI to do so).

Your code should also include a function to print out the board, in ASCII. For example, here is a plausible print out after two turns - one from player 'x' and player 'o':

* * * * * * *
* * * * * * *
* * * * * * *
* * * * * * *
* x O * * * *
"""

class Connect4Board

  # Initialize the game board
  def initialize(ncolumns, nrows, player1, player2, debug=false)
    @logger = Logger.new(STDOUT)
    if debug
      @logger.level = Logger::DEBUG
    else
      @logger.level = Logger::INFO
    end
    @ncolumns = ncolumns
    @nrows = nrows
    @board = []
    @imove = 0
    @last_player = player2
    @empty = '*'
    @game_over = false
    ncolumns.times {
      row = []
      nrows.times {
        row.push(@empty)
      }
      @board.push(row)
    }
  end

  # This method is primarily for testing
  def set_cell(icolumn, irow, val)
    @board[icolumn][irow] = val
  end

  # Check a given sequence (row or column or diagonal) for 4 in a column
  def check_sequence_for_winner(sequence)
    nconseq = 0
    if (! sequence.kind_of?(Array)) or sequence.length < 4
      return false
    end
    @logger.debug "Checking sequence:  " + sequence.inspect
    last_val = sequence.shift # leftmost pop
    if last_val != @empty
      nconseq = 1
    end
    sequence.each { |val|
      if val == @empty
        return check_sequence_for_winner(sequence)
      end
      if val == last_val
        nconseq = nconseq + 1
        if nconseq == 4
          return val
        end
      else
        return check_sequence_for_winner(sequence)
      end
    }
    return false
  end

  # Get a single diagonal starting at icolumn, irow
  def get_diagonal(icolumn0, irow0, left2right)
    seq = []
    @logger.debug irow0.inspect + ' ' + icolumn0.inspect
    irow = irow0
    icolumn = icolumn0
    until icolumn>=@ncolumns or irow>=@nrows do
      jrow = @nrows-irow-1
      if not left2right
        @logger.debug 'right to left:  ' + icolumn.inspect + ' ' + irow.inspect
        val = @board[icolumn][irow]
        @logger.debug icolumn.inspect + ' ' + irow.inspect + ' ' + val.inspect
      else
        val = @board[icolumn][jrow]
        @logger.debug 'left to right: ' + icolumn.inspect + ' ' + jrow.inspect + ' ' + val.inspect
      end
      if val.nil?
        display()
        @logger.error "val should never be nil!"
        abort
      end
      seq.push(val)
      icolumn = icolumn + 1
      irow = irow + 1
    end
    return seq
  end

  # Get all the diagonals
  def get_diagonals()
    diagonals = []
    # Upper left to lower right
    (0..@nrows).each { |irow0|
      (0..@ncolumns).each { |icolumn0|
        @logger.debug icolumn0.inspect + ' ' + irow0.inspect
        diag = get_diagonal(icolumn0, irow0, true)
        diagonals.push(diag)
      }
    }
    # Upper right to lower leftt
    (0..@nrows).each { |irow0|
      (0..@ncolumns).each { |icolumn0|
        jcolumn = @ncolumns - icolumn0 -1
        diagonals.push(get_diagonal(jcolumn, irow0, false))
      }
    }
    return diagonals
  end

  def get_flattened_board
    return @board.flatten
  end

  # Display the current game board state
  def display()
    # TODO:  If winner, highlight the winning sequence
    @logger.info ''
    @logger.info "Move # #{@imove}"
    @logger.debug @board.inspect
    (1..@nrows).each { |irow|
      row = []
      (1..@ncolumns).each { |icol|
        @logger.debug icol.inspect + ' ' + irow.inspect
        row.push(@board[icol-1][irow-1])
      }
      @logger.info row.join('|')
    }
    @logger.info ''
  end

  #initialize_board(@ncolumns, @nrows)
  #display()
  #abort

  # Declare a winner, display the game board
  def declare_winner(winner)
    @game_over = true
    @logger.info "Winner!  Congrats #{winner}"
    #display()
    return winner
  end

  # Check for a winner after most recent legal move
  def check_winner()
    # Horizontal
    (1..@nrows).each { |irow|
      seq = []
      (1..@ncolumns).each { |icolumn|
        seq.push(@board[icolumn-1][irow-1])
      }
      @logger.debug seq.inspect
      result = check_sequence_for_winner(seq)
      if result != false
        declare_winner(result)
        return result
      end
    }
    # Vertical
    (1..@ncolumns).each { |icolumn|
      seq = []
      (1..@nrows).each { |irow|
        seq.push(@board[icolumn-1][irow-1])
      }
      result = check_sequence_for_winner(seq)
      if result != false
        declare_winner(result)
        return result
      end
    }

    # Diagonals
    diagonals = get_diagonals()
    diagonals.each { |seq|
      @logger.debug seq.inspect
      result = check_sequence_for_winner(seq)
      if result != false
        declare_winner(result)
        return result
      end
    }
    return false
  end

  # Get a row from the board
  def row_from_board(row_number)
    #transposed_board = @board.clone.transpose
    #return transposed_board[row_number]
    return @board[row_number]
  end

  # Update the game board
  def update_board(column, row, player)
    if player.nil?
      @logger.error "Player should not be nil!"
      abort
    end
    @board[column][row] = player
  end

  # Process the move of dropping a piece in a row
  def process_move(player, drop_column)
    if not check_legal_move(player, drop_column)
      @logger.info "Move not legal"
      return false
    end
    i = @ncolumns - 1
    while i>=0 do
      val = @board[drop_column][i]
      if val == @empty
        # Found a valid move
        update_board(drop_column, i, player)
        @last_player = player
        @imove = @imove + 1
        return
      end
      i = i - 1
    end
    @logger.debug "Illegal move, row already full"
  end

  # See if a move is legal
  def check_legal_move(player, drop_row)
    if @game_over
      return false
    end
    if player == @last_player
      @logger.debug "Not your turn: " + player
      return false
    end
    row = row_from_board(drop_row)
    if row.select{|cell| cell == @empty} == 0
      # Full row, illegal move
      @logger.info "ILLEGAL MOVE, COLUMN FULL"
      return false
    end
    return true
  end
end
