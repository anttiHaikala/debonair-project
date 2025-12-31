class Room
  attr_accessor :x, :y, :w, :h
  def initialize(x, y, w, h)
    @x = x
    @y = y
    @w = w
    @h = h
  end

  def center_x
    return (x + (w / 2)).to_i
  end
  
  def center_y
    return (y + (h / 2)).to_i
  end

  def intersects?(other)
    return !(@x + @w < other.x || other.x + other.w < @x ||
             @y + @h < other.y || other.y + other.h < @y)
  end

  def color
    hue_seed = @x * 37 + @y * 57 + @w * 23 + @h * 43 # random for each room
    hue = hue_seed % 360
    saturation = 100
    lightness = 80
    rgb = Color.hsl_to_rgb(hue, saturation, lightness)
    return rgb
  end

end

class Corridor
  attr_accessor :x1, :y1, :x2, :y2, :steps, :name
  def initialize(x1, y1, x2, y2)
    @x1 = x1
    @y1 = y1
    @x2 = x2
    @y2 = y2
    @name = random_name
    @steps = []
  end

  def random_name
    prefixes = ["Shadow", "Whispering", "Silent", "Dark", "Hidden", "Misty", "Ancient", "Forgotten", "Creeping", "Twisted", 'Glowing', "Minstrel's", 'Dwarven', 'Orcish', 'Elven', 'Goblin', 'Haunted', 'Crystal', 'Golden', 'Silver', 'Bronze', 'Iron', 'Copper', 'Rainbow', 'Silent', 'Noisy']
    suffixes = ["Passage", "Way", "Path", "Tunnel", "Route", "Hall", "Gallery", "Avenue", "Lane", "Drive", 'Hallway', 'Walk', 'Run', 'Ring', 'Trail', 'Haunt', 'Block', 'Boulevard', 'Laneway', 'Loop', 'Promenade', 'Track', 'Sneak', 'Subway', 'Sprint', 'Alley', 'Marathon', 'Broadway', 'Shortcut', 'Byway']
    prefix = prefixes.sample
    suffix = suffixes.sample
    return "#{prefix} #{suffix}"
  end

  def color
    hue_seed = @x1 * 37 + @y1 * 57 + @x2 * 23 + @y2 * 43 # random for each room
    hue = hue_seed % 360
    saturation = 100
    lightness = 80
    rgb = Color.hsl_to_rgb(hue, saturation, lightness)
    return rgb
  end

end