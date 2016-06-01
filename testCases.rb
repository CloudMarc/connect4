require_relative "connect4"
require "test/unit"

class TestSimpleNumber < Test::Unit::TestCase

  def setup
    @test_players = ['X','O']
    @test_ncolumns = 7
    @test_nrows = 6
    @test_board = Connect4Board.new(@test_ncolumns, @test_nrows,
    @test_players.first, @test_players.last)
  end

  def test_winner_sequence
    sequence = ["X", "*", "O", "O", "O", "O", "*"]
    result = @test_board.check_sequence_for_winner(sequence)
    assert_equal(result, @test_players.last)

    sequence = ["X", "*", "O", "*", "O", "O", "*"]
    result = @test_board.check_sequence_for_winner(sequence)
    assert(!result)

    sequence = []
    result = @test_board.check_sequence_for_winner(sequence)
    assert(!result)

    sequence = ["X"]
    result = @test_board.check_sequence_for_winner(sequence)
    assert(!result)

    sequence = ["X","X"]
    result = @test_board.check_sequence_for_winner(sequence)
    assert(!result)

    sequence = ["X","X","X"]
    result = @test_board.check_sequence_for_winner(sequence)
    assert(!result)

    sequence = ["X","X","X","X"]
    result = @test_board.check_sequence_for_winner(sequence)
    assert_equal(result, @test_players.first)

    sequence = ["*","X","X","X","X"]
    result = @test_board.check_sequence_for_winner(sequence)
    assert_equal(result, @test_players.first)

    sequence = ["*","*","X","X","X","X"]
    result = @test_board.check_sequence_for_winner(sequence)
    assert_equal(result, @test_players.first)

    sequence = ["O","*","X","X","X","X"]
    result = @test_board.check_sequence_for_winner(sequence)
    assert_equal(result, @test_players.first)
  end

  # TODO:  Unit tests for diagonals

  def get_test_cases()
    test_cases = []
    test_cases.push("""
    X|X|O|O|X|X|*
    O|O|X|O|X|O|X
    X|O|O|X|O|X|O
    O|O|X|X|X|O|X
    X|X|O|O|X|O|O
    O|O|X|X|O|X|X
    """)
    test_cases.push("""
    X|X|O|O|X|X|*
    O|O|X|O|X|O|X
    X|O|O|X|O|X|O
    O|O|X|X|X|O|X
    X|X|O|O|X|O|O
    O|O|X|X|O|X|X
    """)
    test_cases.push("""
    X|X|X|O|X|O|*
    X|O|O|O|X|O|X
    X|O|O|X|O|X|O
    O|O|X|X|X|O|X
    X|X|O|O|X|O|X
    O|O|X|X|O|X|X
    """
    )
    test_cases.push("""
    *|*|*|*|*|*|*
    *|*|*|*|*|*|*
    *|*|X|*|*|*|*
    *|O|X|*|*|*|X
    O|O|O|O|*|*|X
    O|O|X|X|X|O|X
    """)
    test_cases.push("""
    *|*|*|*|*|*|*
    O|X|*|*|*|*|*
    X|X|*|O|*|*|O
    O|X|*|O|*|*|X
    X|O|X|X|*|O|O
    X|O|O|X|*|O|X
    """)
    test_cases.push("""
    *|*|*|*|*|*|*
    *|*|*|*|*|*|*
    *|*|*|*|*|*|*
    X|*|*|*|*|*|*
    X|*|*|*|*|*|*
    X|*|O|O|O|O|*
    """)

    return test_cases

  end

  def test_various_cases
    test_cases = get_test_cases()
    test_cases.each { |test_case|
      i = 0
      test_case.split(" ").each { |column|
        j = 0
        column.split("|").each { |cell|
          #puts "column #{j}, row #{i}, value #{cell}"
          @test_board.set_cell(j, i, cell)
          j = j + 1
        }
        i = i + 1
      }
      @test_board.display()
      result = @test_board.check_winner()
      puts result.inspect

    }
  end

  def test_horizontal
    (0..3).each { |icol|
      @test_board.process_move(@test_players.first, icol)
      result = @test_board.check_winner()
      if icol==3
        assert_equal(result, @test_players.first, 'After 4 moves, player1 should win')
        if result==@test_players.first
          return
        else
          @test_board.display()
        end
      else
        assert(!result, 'Not enough moves yet')
      end
      @test_board.process_move(@test_players.last , icol)
      result = @test_board.check_winner()
      assert(!result, 'Second player should not win')
    }
  end

  def test_horizontal_right
    (0..3).each { |icol|
      @test_board.process_move(@test_players.first, @test_ncolumns-icol-1)
      @test_board.display()
      result = @test_board.check_winner()
      if icol==3
        assert_equal(result, @test_players.first, 'After 4 moves, player1 should win')
        if result==@test_players.first
          return
        else
          @test_board.display()
        end
      else
        assert(!result, 'Not enough moves yet')
      end
      @test_board.process_move(@test_players.last , @test_ncolumns-icol-1)
      result = @test_board.check_winner()
      assert(!result, 'Second player should not win')
    }
  end

  def test_vertical
    (0..3).each { |irow|
      @test_board.process_move(@test_players.first, 0)
      @test_board.display()
      result = @test_board.check_winner()
      if irow==3
        assert_equal(result, @test_players.first, 'After 4 moves, player1 should win')
      else
        assert(!result, 'Not enough moves yet')

      end
      @test_board.process_move(@test_players.last , 1)
      @test_board.display()
    }
  end

  def test_vertical_right
    (0..3).each { |irow|
      @test_board.process_move(@test_players.first, 6)
      @test_board.display()
      result = @test_board.check_winner()
      if irow==3
        assert_equal(result, @test_players.first, 'After 4 moves, player1 should win')
      else
        assert(!result, 'Not enough moves yet')
      end
      res = @test_board.process_move(@test_players.last , 1)
      if irow==3
        assert(!res, 'No moves after game over')
      end
      result = @test_board.check_winner()
      assert_not_equal(result, 'O', 'Player 2 cannot this test')
      @test_board.display()
    }
  end

  def test_diag
    # up and to right
    @test_board = Connect4Board.new(@test_ncolumns, @test_nrows,
    @test_players.first, @test_players.last,
    false)
    icol = 0
    @test_board.process_move(@test_players.first, icol)
    @test_board.process_move(@test_players.last , icol+1)
    @test_board.process_move(@test_players.first, icol+1)
    @test_board.process_move(@test_players.last , icol+2)
    @test_board.process_move(@test_players.first, icol+4)
    @test_board.process_move(@test_players.last , icol+3)
    @test_board.process_move(@test_players.first, icol+5)
    @test_board.process_move(@test_players.last , icol+2)
    @test_board.process_move(@test_players.first, icol+2)
    @test_board.process_move(@test_players.last , icol+3)
    @test_board.process_move(@test_players.first, icol+3)
    @test_board.process_move(@test_players.last , icol+5)
    @test_board.process_move(@test_players.first, icol+3)
    result = @test_board.check_winner()
    @test_board.display()
    assert_equal(@test_players.first, result, 'Player1 should win')
  end
  def test_diag_right_to_left
    # up and to left
    icol = @test_ncolumns-1
    @test_board.process_move(@test_players.first, icol)
    @test_board.process_move(@test_players.last , icol-1)
    @test_board.process_move(@test_players.first, icol-1)
    @test_board.process_move(@test_players.last , icol-2)
    @test_board.process_move(@test_players.first, icol-4)
    @test_board.process_move(@test_players.last , icol-3)
    @test_board.process_move(@test_players.first, icol-5)
    @test_board.process_move(@test_players.last , icol-2)
    @test_board.process_move(@test_players.first, icol-2)
    @test_board.process_move(@test_players.last , icol-3)
    @test_board.process_move(@test_players.first, icol-3)
    @test_board.process_move(@test_players.last , icol-5)
    @test_board.process_move(@test_players.first, icol-3)
    result = @test_board.check_winner()
    @test_board.display()
    assert_equal(@test_players.first, result, 'Player1 should win')
  end

  def test_random_game
    # Test is all by repeatedly processing moves, whether legal or not,
    # with random selections of Player and drop row
    200.times  do
      @test_board.process_move(@test_players.sample, rand(@test_ncolumns))
      @test_board.display()
      result = @test_board.check_winner()
      if @test_players.include?(result)
        return true
      end
    end
    @test_board.display()
  end

end
