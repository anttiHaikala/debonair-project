# this class includes things that appear on top of floor tiles: 
# doors, beds, chairs, tables, trees, plants
# 
# furniture roration defaults:
# dors: 0 stands east-west, 90 stands north-south
# beds: 0 head on north side, 90 head on east side
# chairs: 0 faces north, 90 faces east
class Furniture

  attr_accessor :kind
  attr_accessor :x
  attr_accessor :y
  attr_accessor :depth
  attr_accessor :material
  attr_accessor :rotation # 0, 90, 180, 270 degrees
  attr_accessor :seen_by_hero
  attr_accessor :x_when_seen # we WILL need these when monsters or events start moving things around
  attr_accessor :y_when_seen 

  def initialize(kind, material, x, y, depth, rotation=0)
    @kind = kind
    @x = x
    @y = y
    @depth = depth
    @material = material
    @rotation = 0
    @seen_by_hero = false
  end

  def  self.kinds
    [
    :door,
    :bed,
    :chair,
    :table
  ]
  end

  def self.materials
    [
    :wood,
    :stone,
    :metal
  ]
  end

  def c
    [13,2]
  end

  # hsl color (cheat shett: https://www.rapidtables.com/convert/color/rgb-to-hsl.html)
  def color
    return [40, 30, 40]
  end

  def title(args)
    return "#{@material.to_s} #{@kind.to_s}"
  end
end