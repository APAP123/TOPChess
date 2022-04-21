# Text parser to parse player inputs from long algorithmic notation
# Into array coordinates
class Parser
  # Lookup table for notation to array coordinates
  NOTATION_LOOKUP = {
    'a' => 0,
    'b' => 1,
    'c' => 2,
    'd' => 3,
    'e' => 4,
    'f' => 5,
    'g' => 6,
    'h' => 7,
    '1' => 7,
    '2' => 6,
    '3' => 5,
    '4' => 4,
    '5' => 3,
    '6' => 2,
    '7' => 1,
    '8' => 0
  }.freeze

  # 'reverse' lookup table for y-axis to notation
  Y_LOOKUP = {
    0 => '8',
    1 => '7',
    2 => '6',
    3 => '5',
    4 => '4',
    5 => '3',
    6 => '2',
    7 => '1'
  }.freeze

  # 'reverse' lookup table for x-axis to notation
  X_LOOKUP = {
    0 => 'a',
    1 => 'b',
    2 => 'c',
    3 => 'd',
    4 => 'e',
    5 => 'f',
    6 => 'g',
    7 => 'h'
  }.freeze

  # Returns true if the entered string matches
  # long algorithmic notation format
  def self.standard_format?(string)
    return false if string.match(/[a-h][1-8][a-h][1-8]/).nil?

    true
  end

  # Returns true if string matches castling format
  def self.castling_format?(string)
    return true if string == 'O-O' # kingside
    return true if string == 'O-O-O' # queenside

    false
  end

  # Returns opcodes determined by the user's input
  def self.read_input(string)
    return 1 if standard_format?(string)
    return 2 if castling_format?(string)
    return 3 if string.downcase == 'save' || string.downcase == 's' # Saves the game

    -1
  end

  # Takes coordinates of desired piece and desired location
  # in long notation and returns them in array-coordinate formatting
  def self.alg_to_array(string)
    # Since we know the length will always be four, we can access
    # the individual characters directly rather than needing to
    # iterate through the string.
    location = [NOTATION_LOOKUP[string[1]], NOTATION_LOOKUP[string[0]]]
    goal = [NOTATION_LOOKUP[string[3]], NOTATION_LOOKUP[string[2]]]

    [location, goal]
  end

  # Returns chess notation Y-value from a given array value
  def self.y_lookup(value)
    Y_LOOKUP[value]
  end

  # Returns chess notation X-value from a given array value
  def self.x_lookup(value)
    X_LOOKUP[value]
  end

  # Returns true if the chosen amount of players is valid
  def self.valid_players?(input)
    case input
    when '0'
      true
    when '1'
      true
    when '2'
      true
    else
      false
    end
  end

  # Returns true if passed 'L' or 'Load' (case-insensitive)
  def self.load_game?(input)
    case input.downcase
    when 'l'
      true
    when 'load'
      true
    else
      false
    end
  end
end
