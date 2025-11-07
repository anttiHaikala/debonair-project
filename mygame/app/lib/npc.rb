class NPC < Entity
  attr_accessor :char, :species, :emote, :has_been_seen

  def initialize(species, emote, x = 0, y = 0)
    @kind = :npc
    @species = species
    @emote = emote
    @has_been_seen = false
    @home = [x, y]
    @home_level = nil
    super(x, y)
  end

  def color
    case @species
    when 'goblin'
      return [20, 125, 20]
    when 'grid bug'
      return [255, 0, 255]
    when 'rat'
      return [80, 70, 48]
    else
      return [255, 255, 255]
    end
  end
  
  def c
    case @species
    when 'goblin'
      return [8,4]
    when 'grid bug'
      return [8,7]
    when 'rat'
      return [2,7]
    else
      return [16,14]
    end
  end

  def perform_emote
    puts "#{@species} performs emote: #{@emote}"
  end

  def speak
    puts "#{@species} says: #{@dialogue}"
  end

  def self.populate_dungeon(dungeon, args)
    for level in dungeon.levels
      self.populate_level(level, args)
    end
  end

  def self.populate_level(level, args)
    level.rooms.each do |room|
      case args.state.rng.d6
      when 1
        npc = NPC.new('goblin', 'grins mischievously', room.center_x, room.center_y, level.depth)
        level.entities << npc
      when 2
        npc = NPC.new('grid bug', 'makes weird noise', room.center_x, room.center_y, level.depth)
        level.entities << npc
      when 3
        npc = NPC.new('rat', 'growls hungrily', room.center_x, room.center_y, level.depth)
        level.entities << npc
      end
    end
  end
end