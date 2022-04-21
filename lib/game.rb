require './lib/chess'
require './lib/piece'
require './lib/parser'

human_players = nil

# Prompts for the player to load a game and returns true if so
def load_game?
  puts 'Would you like to start a new game or load a previously saved game?'
  puts "Enter 'L' or 'load' to load a game, or anything else to start a new game."
  Parser.load_game?(gets.chomp)
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
  end
end

if load_game?
  chess = Chess.new(nil)
  chess.load_game(verify_file)
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

chess.play
