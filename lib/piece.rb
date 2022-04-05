# Base class for all game pieces to inherit from
class Piece
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

    current_y = location[0] + y_counter
    current_x = location[1] + x_counter
    until current == goal
      return false if board[current_y][current_x] != ' '

      current_y += y_counter
      current_x += x_counter
    end

    true
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
end

# Class representation of the Rook piece
class Rook < Piece
  def valid_move?(location, goal)
    # check if goal is straight line (i.e. one of the axii must remain the same)
    # Then need to make sure no pieces are between it and goal
    if (location[0] == goal[0] || location[1] == goal[1]) & inbounds?(goal)
      return true
    end

    false
  end
end
