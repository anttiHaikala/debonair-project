class Level
  attr_accessor :depth, :levels, :tiles
  attr_accessor :floor_hue # this determines the color scheme of the level
  attr_accessor :vibe # this is a placeholder for different styles of level

  def initialize
    @tiles = []
    @floor_hue = rand(360)
    @vibe = :normal
  end

end