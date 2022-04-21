# Main driver of the game.
require 'json'
require './lib/piece'
require './lib/parser'

# Class representation of Chess
class Chess
  attr_reader :board

  # Simple lookup for getting player colors in string form
  COLOR = {
    -1 => 'Black',
    1 => 'White'
  }.freeze

  def initialize(board, player = 1)
    @board = board
    @player = player # Current player; 1 is white, -1 is black
    @en_passant = false # If true, en passant maneuver occurs
    @last_moved_piece = nil
  end

  # Returns a deep copy of the Chess object.
  def clone
    dummy_board = Array.new(8) { Array.new(8) }

    (0..@board.length-1).each do |y|
      (0..@board.length-1).each do |x|
        dummy_board[y][x] = @board[y][x].clone
      end
    end

    Chess.new(dummy_board, @player)
  end

  # Dumps game into .json format
  def dump_json
    JSON.dump ({
      board: @board,
      player: @player,
      en_passant: @en_passant,
      last_moved_piece: @last_moved_piece
    })
  end

  # Saves game as file in working directory
  def save_game
    puts 'Save game as?'
    file = gets.chomp
    File.open("#{file}.json", 'w') { |f| f.write (dump_json) }
    puts "Game saved as #{file}.json"
  end

  # Loads games from JSON-formatted save
  def load_game(string)
    data = JSON.parse string
    @board = data['board']
    @player = data['player']
    @en_passant = data['en_passant']
    @last_moved_piece = data['last_moved_piece']
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

  # Returns true if a move made would put the current player's King in check
  def simulated_check?(location, goal)
    simulated_game = clone
    simulated_game.move_piece(location, goal)
    simulated_game.check?
  end

  # Returns location of current player's King in [y, x] coordinates
  def find_king
    (0..7).each do |y|
      (0..7).each do |x|
        if (@board[y][x].is_a? King) && @board[y][x].color == @player
          return [y, x]
        end
      end
    end
    puts 'Either your King is gone or this method broke.'
  end

  # Checks if current player's King is currently in check.
  def check?
    # todo
    king = find_king
    opponent = @player * -1
    # Iterate through the board looking for pieces of the opposite color
    (0..7).each do |y|
      (0..7).each do |x|
        if !@board[y][x].nil? && @board[y][x].color == opponent
          # Check if opponent's piece is threatening King
          return true if @board[y][x].valid_move?([y, x], king, @board)
        end
      end
    end
    false
  end

  # Returns true if every move a piece can make leaves the king in check
  def all_simulated_checks?(location)
    (0..7).each do |y| # Iterate through every space on the board
      (0..7).each do |x|
        # Check if the space is a valid one to move the piece to
        if @board[location[0]][location[1]].valid_move?(location, [y, x], @board)
          # If moving the piece results in the king not being in check, return false
          return false unless simulated_check?(location, [y, x])
        end
      end
    end
    true
  end

  # Returns true if any move made by the player would result in a check
  def stalemate?
    (0..7).each do |y|
      (0..7).each do |x|
        if !@board[y][x].nil? && @board[y][x].color == @player
          return false unless all_simulated_checks?([y, x])
        end
      end
    end
    true
  end

  # Returns true if all legal moves this turn would leave the player in check
  def checkmate?
    return true if check? && stalemate?

    false
  end

  # Moves the piece on location to goal
  def move_piece(location, goal)
    @board[goal[0]][goal[1]] = @board[location[0]][location[1]]
    @board[location[0]][location[1]] = nil

    if @en_passant
      @board[@last_moved_piece[0]][@last_moved_piece[1]] = nil
      @en_passant = false
    end

    @last_moved_piece = goal
  end

  # Checks if the current player can castle or not
  def can_castle?(rook_loc, king_loc)
    rook = @board[rook_loc[0]][rook_loc[1]]
    king = @board[king_loc[0]][king_loc[1]]
    side = (rook_loc[1] - king_loc[1]) <=> 0 # Negative queenside, positive king

    return false unless (rook.is_a? Rook) && (king.is_a? King)

    return false if rook.has_moved || king.has_moved

    return false unless king.all_clear?(king_loc, rook_loc, @board)

    return false if check?(board)

    return false if simulated_check?(king_loc, [king_loc[0], king_loc[1] + side])

    true
  end

  # If can_castle?, performs a castling move and returns true
  def castling(string)
    # First check if Rook and King are in position
    @player == 1 ? row = 7 : row = 0
    string == 'O-O' ? rook_x = 0 : rook_x = 7

    unless can_castle?([row, rook_x], [row, 4])
      puts "You can't castle right now!"
      return false
    end

    direction = @board[row][4].counter(4, rook_x)
    @board[row][4 + (direction * 2)] = @board[row][4]
    @board[row][4 + direction] = @board[row][rook_x]
    # Need to clear spaces the pieces just left
    @board[row][4] = nil
    @board[row][rook_x] = nil
    true
  end

  # Returns true if en passant is available
  def en_passant?(location, goal)
    # If the goal is located in front and to the left or right of the moving pawn
    if goal[0] == location[0] - @player && (goal[1] == location[1] - 1 || goal[1] == location[1] + 1)
      if [location[0], location[1] - 1] == @last_moved_piece || [location[0], location[1] + 1] == @last_moved_piece
        puts 'en passant!'
        @en_passant = true
        return true
      end
    end
    false
  end

  # Returns true if the desired turn passes a whole bunch of checks.
  def valid_turn?(location, goal)
    if (@board[location[0]][location[1]].is_a? Pawn) && en_passant?(location, goal)
      @en_passant = true
      return true
    end

    unless valid_piece?(location)
      puts "You don't have a piece there!"
      return false
    end

    if simulated_check?(location, goal)
      puts "You can't put yourself in check!"
      return false
    end

    unless board[location[0]][location[1]].valid_move?(location, goal, board)
      puts "This piece can't move there!"
      return false
    end

    true
  end

  # Represents one player's turn in a match.
  def take_turn
    puts "#{COLOR[@player]} player, please enter your move."
    loop do
      input = gets.chomp

      case Parser.read_input(input)
      when 1
        # standard format; continue with loop
      when 2
        castling(input) ? break : next
      when 3
        # TODO: save game
        next
      else
        next
      end

      coordinate_pair = Parser.alg_to_array(input)
      location = coordinate_pair[0]
      goal = coordinate_pair[1]
      next unless valid_turn?(location, goal)

      move_piece(location, goal)
      break
    end
  end

  # Main driver of the game; checks for win conditions, swaps players after each turn.
  def play
    loop do
      draw_board
      if checkmate?
        puts "Checkmate! #{COLOR[@player * -1]} wins!"
        return
      end
      take_turn
      @player *= -1
    end
  end

  # Draws board out to screen
  def draw_board
    puts '  a b c d e f g h'
    (0..board.length - 1).each do |y|
      print "#{Parser.y_lookup(y)}|"
      (0..board[y].length - 1).each do |x|
        if board[y][x].nil?
          if (y.even? && x.even?) || (y.odd? && x.odd?)
            print '■ '
          else
            print '□ '
          end
          next
        end
        print "#{board[y][x].draw_me} "
      end
      puts "|#{Parser.y_lookup(y)}\n"
    end
    puts '  a b c d e f g h'
  end
end
