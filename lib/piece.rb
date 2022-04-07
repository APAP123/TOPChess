# Base class for all game pieces to inherit from
# Perhaps run inbound before valid_move?(); that would save a few rewrites.
class Piece
  attr_reader :color
  def initialize(color)
    # todo
    @color = color # 1 for white, -1 for black
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
      return false if board[current[0]][current[1]] != ' '

      current[0] += y_counter
      current[1] += x_counter
    end

    true
  end

  # Returns the Piece's unicode representation
  def draw_me
    '?'
  end
end

# Class representation of the Pawn piece
class Pawn < Piece
  @has_moved = false
  # Returns true if the passed movement is valid
  def valid_move?(location, goal)
    # one space in front;
    # if first time pawn is moving, can optionally move two spaces in front
    # Don't forget en passant
    if goal[0] == location[0] - (1 * color)
      @has_moved = true
      return true
    end

    if !@has_moved && goal[0] == location[0] - (2 * color)
      @has_moved = true
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
  def valid_move?(location, goal)
    # check if goal is straight line (i.e. one of the axii must remain the same)
    # Then need to make sure no pieces are between it and goal
    return true if location[0] == goal[0] || location[1] == goal[1]

    false
  end

  # Returns the Piece's unicode representation
  def draw_me
    @color == 1 ? '♖' : '♜'
  end
end

# Class representation of the Bishop piece
class Bishop < Piece
  def valid_move?(location, goal)
    # For a Bishop's move to be valid, both axii must change from location to goal
    # In addition, the factor of change must be equal for the two axii
    # i.e., both axii should change by the same absolute value
    # return true if location[0] != goal[0] && location[1] != goal[1] # this is probably redundant
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
  def valid_move?(location, goal)
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
  # We override the all_clear?() method to always return true
  def all_clear?(location, goal, board)
    true
  end

  def valid_move?(location, goal)
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
  def valid_move?(location, goal)
    # Same as Queen, but can only move one space in any direction.
    y_factor = (location[0] - goal[0]).abs
    x_factor = (location[1] - goal[1]).abs
    eturn false if y_factor > 1 || x_factor > 1

    true
  end

  # Returns the Piece's unicode representation
  def draw_me
    @color == 1 ? '♔' : '♚'
  end
end
