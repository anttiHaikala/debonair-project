class Entity
  attr_accessor :level, :x, :y, :kind
  def initialize(x, y, kind = :generic)
    @x = x
    @y = y
    @kind = kind
  end
end