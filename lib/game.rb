require './lib/chess'
require './lib/piece'
require './lib/parser'

human_players = nil

  # Simple lookup for getting player colors in string form
  COLOR = {
    -1 => 'Black',
    1 => 'White'
  }.freeze

# Prompts for the player to load a game and returns true if so
def load_game?
  puts 'Would you like to start a new game or load a previously saved game?'
  puts "Enter 'L' or 'load' to load a game, or anything else to start a new game."
  Parser.load_game?(gets.chomp)
end

  # Saves game as file in working directory
  def save_game(chess)
    puts 'Save game as?'
    file = gets.chomp
    File.open("#{file}.json", 'w') { |f| f.write(chess.dump_json) }
    puts "Game saved as #{file}.json"
  end

# Prompts user for file name and checks if it exists
def verify_file
  puts 'Please enter the name of your saved game, including file extension'
  loop do
    file = gets.chomp
    if File.exist?(file)
      puts 'Loading game...'
      return file
    else
      puts 'File not found! Please try again.'
    end
  end
end

# Prompts for the amount of human players
def choose_players
  loop do
    puts 'how many (human) players?'
    player_count = gets.chomp
    unless Parser.valid_players?(player_count)
      puts 'Invalid amount of players. Please choose 0, 1, or 2.'
      next
    end
    human_players = player_count
    break
  end
end

  # Represents one player's turn in a match.
  def take_turn(chess)
    puts "#{COLOR[chess.player]} player, please enter your move."
    loop do
      input = gets.chomp

      case Parser.read_input(input)
      when 1
        # standard format; continue with loop
      when 2
        chess.castling(input) ? break : next
      when 3
        save_game(chess)
        next
      else
        next
      end
      # debug_print
      coordinate_pair = Parser.alg_to_array(input)
      location = coordinate_pair[0]
      goal = coordinate_pair[1]
      next unless chess.valid_turn?(location, goal)

      chess.move_piece(location, goal)
      chess.promote(goal) if chess.can_promote?(goal)
      break
    end
  end

  # Main driver of the game; checks for win conditions, swaps players after each turn.
  def play(chess)
    loop do
      chess.draw_board
      if chess.checkmate?
        puts "Checkmate! #{COLOR[chess.player * -1]} wins!"
        return
      end
      take_turn(chess)
      chess.swap_players
    end
  end

if load_game?
  chess = Chess.new(nil)
  chess.load_game(File.read(verify_file))
else
  choose_players
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
end

play(chess)
