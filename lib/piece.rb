class Piece
  def initialize(color)
    # todo
    @color = color # 1 for white, -1 for black
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
