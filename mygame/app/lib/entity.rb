class Entity
  attr_accessor :level, :x, :y, :kind, :visual_x, :visual_y
  def initialize(x, y, kind = :generic)
    @x = x
    @y = y
    @kind = kind
    @visual_x = x
    @visual_y = y
  end
end