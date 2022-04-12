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

  # Returns true if the entered string matches
  # long algorithmic notation format
  def self.standard_format?(string)
    if string.match(/[a-h][1-8][a-h][1-8]/).nil?
      puts 'Incorrect formatting! Directions must be in'
      puts '[letter][number][letter][number] format.'
      puts 'For example: g1f3'
      return false
    end

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
    return 3 if string == 'save' # Saves the game

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
end
