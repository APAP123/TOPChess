# Main driver of the game.
require './lib/piece'
require './lib/parser'

# Class representation of Chess
class Chess
  attr_reader :board

  def initialize(board)
    @board = board
    @player = 1 # Current player; 1 is white, -1 is black
  end

  # Returns true if the passed location on the board contains
  # a valid piece that the current player can move.
  def valid_piece?(location)
    # Checks location to make sure there's actually a piece there
    if @board[location[0]][location[1]].nil?
      puts "There's no piece there!"
      return false
    end

    # Checks location for piece belonging to current player
    if @board[location[0]][location[1]].color != @player
      puts "You can't move someone else's piece!"
      puts "DEBUG: You tried to move the piece at: #{location}"
      return false
    end
    true
  end

  # Checks if any player's King is currently in check.
  def check?
    # todo
  end

  # Moves the piece on location to goal
  def move_piece(location, goal)
    @board[goal[0]][goal[1]] = @board[location[0]][location[1]]
    @board[location[0]][location[1]] = nil
  end

  # Checks if the current player can castle or not
  def can_castle?(rook_loc, king_loc)
    rook = @board[rook_loc[0]][rook_loc[1]]
    king = @board[king_loc[0]][king_loc[1]]

    return false unless (rook.is_a? Rook) && (king.is_a? King)
    return false if rook.has_moved && king.has_moved
    return false unless king.all_clear?(king_loc, rook_loc, @board)

    true
  end

  # Castling
  def castling(string)
    # First check if Rook and King are in position
    if string == 'O-O' && @player == -1 # Queenside castle, black's side
      return can_castle?([0, 0], [0, 4])
    end

    if string == 'O-O-O' && @player == -1 # Kingside castle, black's side
      return can_castle?([0, 7], [0, 4])
    end

    if string == 'O-O' && @player == 1 # Queenside castle, white's side
      return can_castle?([7, 0], [7, 4])
    end

    if string == 'O-O-O' && @player == 1 # Kingside castle, white's side
      return can_castle?([7, 7], [7, 4])
    end
  end

  # Represents one player's turn in a match.
  def take_turn
    @player == 1 ? color = 'white' : color = 'black'
    puts "#{color} player, please enter your move."
    loop do
      input = gets.chomp
      until Parser.valid_format?(input)
        input = gets.chomp
      end
      coordinate_pair = Parser.alg_to_array(input)
      location = coordinate_pair[0]
      goal = coordinate_pair[1]
      next unless valid_piece?(location)

      unless @board[location[0]][location[1]].valid_move?(location, goal)
        puts "This piece can't move there!"
        next
      end

      unless @board[location[0]][location[1]].all_clear?(location, goal, @board)
        puts "There's other pieces in the way!"
        next
      end

      move_piece(location, goal)
      break
    end
  end

  # Main driver of the game; checks for win conditions and swaps players after each turn.
  def play
    loop do
      draw_board
      take_turn
      @player *= -1
    end
  end

  # Draws board out to screen
  def draw_board
    (0..board.length - 1).each do |y|
      (0..board[y].length - 1).each do |x|
        if board[y][x].nil?
          if (y.even? && x.even?) || (y.odd? && x.odd?)
            print '■'
          else
            print '□'
          end
          next
        end
        print board[y][x].draw_me
      end
      puts "\n"
    end
  end
end

board = [
  [Rook.new(-1), Knight.new(-1), Bishop.new(-1), Queen.new(-1), King.new(-1), Bishop.new(-1), Knight.new(-1), Rook.new(-1)],
  [Pawn.new(-1), Pawn.new(-1), Pawn.new(-1), Pawn.new(-1), Pawn.new(-1), Pawn.new(-1), Pawn.new(-1), Pawn.new(-1)],
  [nil, nil, nil, nil, nil, nil, nil, nil],
  [nil, nil, nil, nil, nil, nil, nil, nil],
  [nil, nil, nil, nil, nil, nil, nil, nil],
  [nil, nil, nil, nil, nil, nil, nil, nil],
  [Pawn.new(1), Pawn.new(1), Pawn.new(1), Pawn.new(1), Pawn.new(1), Pawn.new(1), Pawn.new(1), Pawn.new(1)],
  [Rook.new(1), Knight.new(1), Bishop.new(1), Queen.new(1), King.new(1), Bishop.new(1), Knight.new(1), Rook.new(1)]
]

chess = Chess.new(board)

chess.play