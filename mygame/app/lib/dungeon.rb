class Dungeon
  attr_accessor :levels
  def initialize
    @levels = []
  end

  def max_depth
    return @levels.length
  end
end