# Base class for all game pieces to inherit from
require 'json'
class Piece
  attr_reader :color, :value

  # Returns value of Piece. Note this is NOT material value, but rather
  # an internal value used for saving and loading pieces.
  def value_lookup
    return 1 if self.is_a? Pawn
    return 2 if self.is_a? Knight
    return 3 if self.is_a? Bishop
    return 5 if self.is_a? Rook
    return 9 if self.is_a? Queen
    return 100 if self.is_a? King
  end

  def initialize(color, has_moved = false, value = value_lookup)
    @color = color # 1 for white, -1 for black
    @has_moved = has_moved
    @value = value
  end

  # Dumps Piece to .json
  def dump
    JSON.dump ({
      color: @color,
      has_moved: @has_moved,
      value: @value
    })
  end

  def to_hash
    {
      color: @color,
      has_moved: @has_moved,
      value: @value
    }
  end

  # Returns true if goal is within board boundary
  def inbounds?(goal)
    if goal[0] < 8 && !goal[0].negative? && goal[1] < 8 && !goal[1].negative?
      return true
    end

    false
  end

  # Helper function for all_clear?
  def counter(start, goal)
    case start - goal
    when 0 # same axis
      0
    when -Float::INFINITY..0 # Counting up to goal
      1
    when 0..Float::INFINITY # Counting down to goal
      -1
    end
  end

  # Returns true if there is no piece between the location and goal
  def all_clear?(location, goal, board)
    # Because of the way the 2D array is constructed, Y comes before X
    y_counter = counter(location[0], goal[0])
    x_counter = counter(location[1], goal[1])

    current = Array.new(2)
    current[0] = location[0] + y_counter
    current[1] = location[1] + x_counter

    until current == goal
      return false unless board[current[0]][current[1]].nil?

      current[0] += y_counter
      current[1] += x_counter
    end

    unless board[current[0]][current[1]].nil? || board[current[0]][current[1]].color == @color * -1
      return false
    end

    true
  end

  # Returns a piece of the opposite color that the calling Piece is threatening;
  # Returns nil if no enemy piece is being threatened
  def threatening(location, goal, board)
    # Because of the way the 2D array is constructed, Y comes before X
    y_counter = counter(location[0], goal[0])
    x_counter = counter(location[1], goal[1])

    y = location[0] + y_counter
    x = location[1] + x_counter
    until [y, x] == goal
      unless board[y][x].nil?
        return board[y][x] if board[y][x].color == @color * -1

        return nil
      end

      y += y_counter
      x += x_counter
    end

    nil
  end

  # Returns true if the piece can move to the goal
  def valid_move?(location, goal, board)
    valid_goal?(location, goal, board) && all_clear?(location, goal, board)
  end

  # Returns the Piece's unicode representation
  def draw_me
    '?'
  end
end

# Class representation of the Pawn piece
class Pawn < Piece
  attr_reader :moved_two, :move_count

  def initialize(color, has_moved = false, moved_two = false, move_count = 0, value = value_lookup)
    @color = color # 1 for white, -1 for black
    @has_moved = has_moved
    @moved_two = moved_two
    @move_count = move_count # To do an en passant capture, pawn must have moved exactly 3
    @value = value
  end

  # Dumps Pawn to .json
  def dump
    JSON.dump ({
      color: @color,
      has_moved: @has_moved,
      moved_two: @moved_two,
      move_count: @move_count
    })
  end

  def to_hash
    {
      color: @color,
      has_moved: @has_moved,
      value: @value,
      moved_two: @moved_two,
      move_count: @move_count
    }
  end

  # Returns true if the Pawn can capture an opponent at goal
  def can_capture?(location, goal, board)
    if goal[0] == location[0] - color && (goal[1] == location[1] - 1 || goal[1] == location[1] + 1)
      return true if !board[goal[0]][goal[1]].nil? && board[goal[0]][goal[1]].color == color * -1
    end
    false
  end

  # Returns true if the passed movement is valid
  def valid_goal?(location, goal, board)
    @move_count = 0 if @move_count.nil?

    # one space in front;
    # if first time pawn is moving, can optionally move two spaces in front

    # Moving straight ahead, no capture
    if goal[0] == location[0] - (1 * color) && goal[1] == location[1] &&
       board[goal[0]][goal[1]].nil?
      @has_moved = true
      @move_count += 1
      return true
    end

    if !@has_moved && goal[0] == location[0] - (2 * color) && goal[1] == location[1] &&
       board[goal[0]][goal[1]].nil?
      @has_moved = true
      @moved_two = true
      @move_count += 2
      return true
    end

    # Standard capture
    if can_capture?(location, goal, board)
      @has_moved = true
      @moved_two = true
      @move_count += 1
      return true
    end

    false
  end

  # Returns the Piece's unicode representation
  def draw_me
    @color == 1 ? '♙' : '♟'
  end
end

# Class representation of the Rook piece
class Rook < Piece
  attr_reader :has_moved

  def valid_goal?(location, goal, board)
    # check if goal is straight line (i.e. one of the axii must remain the same)
    # Then need to make sure no pieces are between it and goal
    if location[0] == goal[0] || location[1] == goal[1]
      @has_moved = true
      return true
    end

    false
  end

  # Returns the Piece's unicode representation
  def draw_me
    @color == 1 ? '♖' : '♜'
  end
end

# Class representation of the Bishop piece
class Bishop < Piece
  def valid_goal?(location, goal, board)
    # For a Bishop's move to be valid, both axii must change from location to goal
    # In addition, the factor of change must be equal for the two axii
    # i.e., both axii should change by the same absolute value
    return true if (location[0] - goal[0]).abs == (location[1] - goal[1]).abs

    false
  end

  # Returns the Piece's unicode representation
  def draw_me
    @color == 1 ? '♗' : '♝'
  end
end

# Class representation of the Queen piece
class Queen < Piece
  def valid_goal?(location, goal, board)
    # The Queen has the combined movement of the rook and bishop
    return true if location[0] == goal[0] || location[1] == goal[1]
    return true if (location[0] - goal[0]).abs == (location[1] - goal[1]).abs

    false
  end

  # Returns the Piece's unicode representation
  def draw_me
    @color == 1 ? '♕' : '♛'
  end
end

# Class representation of the Knight piece
class Knight < Piece
  # Since the Knight can hop over pieces,
  # We override all_clear?() to only check destination
  def all_clear?(location, goal, board)
    unless board[goal[0]][goal[1]].nil? || board[goal[0]][goal[1]].color == @color * -1
      return false
    end

    true
  end

  def valid_goal?(location, goal, board)
    # The knight moves in an L-shape: two spaces in a cardinal direction,
    # Then one space in the perpendicular direction.
    valid_spaces = []
    # Y-Axis
    [-2, 2].each do |y|
      [-1, 1].each do |x|
        valid_spaces.append([location[0] + y, location[1] + x])
      end
    end

    # X-Axis
    [-2, 2].each do |x|
      [-1, 1].each do |y|
        valid_spaces.append([location[0] + y, location[1] + x])
      end
    end

    valid_spaces.include? goal
  end

  # Returns the Piece's unicode representation
  def draw_me
    @color == 1 ? '♘' : '♞'
  end
end

# Class representation of the King piece
class King < Piece
  attr_reader :has_moved
  def valid_goal?(location, goal, board)
    # Same as Queen, but can only move one space in any direction.
    y_factor = (location[0] - goal[0]).abs
    x_factor = (location[1] - goal[1]).abs
    return false if y_factor > 1 || x_factor > 1

    @has_moved = true
    true
  end

  # Returns the Piece's unicode representation
  def draw_me
    @color == 1 ? '♔' : '♚'
  end
end
