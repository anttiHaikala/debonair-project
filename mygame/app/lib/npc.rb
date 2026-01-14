class NPC < Entity

  include Needy

  attr_accessor :char, :species, :has_been_seen, :depth, :status, :behaviours, :carried_items, :behaviour, :first_name

  def initialize(species, x = 0, y = 0, depth = 0)
    @kind = :npc
    @species = species
    @has_been_seen = false
    @home = [x, y]
    @home_depth = depth
    @depth = depth
    @status = []
    @traits = []
    super(x, y)
    initialize_needs
    @behaviours = []
    @behaviour = nil # the currently active behaviour
    Behaviour.setup_for_npc(self)
    self.setup_traits
    @first_name = self.generate_first_name
  end

  def name
    if @name
      return @name
    else
      return "#{@traits.join(' ')} #{@species.to_s.gsub('_',' ')}".capitalize.strip
    end
  end  

  # these are HSl values (hue, saturation, level)
  # hue cheat sheet: 0=red, 40=orange, 80=yellow, 120=green, 200=blue, 300=purple
  def color
    return Species.color_for_species(@species)
  end

  def setup_traits
    case @species
    when :goblin, :orc
      @traits << [:skinny, :fat, :short, :tall, :muscular].sample
    when :grid_bug
      @traits << [:shiny, :metallic, :buzzing].sample
    when :rat, :newt
      @traits << [:skinny, :fat, :big, :small, :muscular].sample
    when :wraith
    when :skeleton
    when :minotaur
    when :leprechaun
      @traits << [:cheerful, :grumpy, :mischievous, :sleepy].sample
    end
  end


  def c 
    # x, y character representation from the sprite sheet
    case @species
    when :goblin
      return [7,6]
    when :grid_bug
      return [8,7]
    when :rat 
      return [2,7]
    when :newt
      return [14,6]
    when :orc
      return [15,4]
    when :wraith
      return [7,5]  
    when :skeleton
      return [3,5]
    when :minotaur
      return [13,4]
    when :leprechaun
      return [12,6]
    else
      return [16,14]
    end
  end

  def emote
    case @species
    when :goblin
      return "grins mischievously"
    when :grid_bug
      return "makes weird noise"
    when :rat
      return "growls hungrily"
    when :leprechaun
      return "chuckles"
    else
      return "looks around"
    end
  end

  def self.populate_dungeon(dungeon, args)
    for level in dungeon.levels
      self.populate_level(level, args)
    end
  end

  def self.populate_with_endgame_challenges(level, args)
    level.rooms.each do |room|
      case args.state.rng.d12
      when 1
        npc = NPC.new(:minotaur, room.center_x, room.center_y, level.depth)
        level.entities << npc
      when 2
        npc = NPC.new(:skeleton, room.center_x, room.center_y, level.depth)
        npc.carried_items << Weapon.generate_for_npc(npc, level.depth, args)
        level.entities << npc
      when 3
        npc = NPC.new(:wraith, room.center_x, room.center_y, level.depth)
        level.entities << npc
      end
    end
  end

  def self.populate_level(level, args)
    level.rooms.each do |room|
      case args.state.rng.d6
      when 1
        if level.depth < 6
          mobtype = :goblin
        else
          mobtype = :orc
        end
        npc = NPC.new(mobtype, room.center_x, room.center_y, level.depth)
        npc.carried_items << Weapon.generate_for_npc(npc, level.depth, args)
        level.entities << npc
        level_mod = (level.depth / 10).floor
        level_mod.times do |i|
          new_npc = NPC.new(mobtype, room.center_x + Numeric.rand(-2..2), room.center_y + Numeric.rand(-2..2), level.depth)
          new_npc.carried_items << Weapon.generate_for_npc(npc, level.depth, args)
          level.entities << new_npc
        end
      when 2
        if level.depth < 4
          npc = GridBug.new(room.center_x, room.center_y, level.depth)
          level.entities << npc
        elsif level.depth < 8
          npc = NPC.new(:skeleton, room.center_x, room.center_y, level.depth)
          level.entities << npc
        else
          npc = NPC.new(:wraith, room.center_x, room.center_y, level.depth)
          level.entities << npc
        end
      when 3
        case level.vibe
          when :lush
            kind = :newt
          else
            kind = :rat
        end
        npc = NPC.new(kind, room.center_x, room.center_y, level.depth)
        level.entities << npc
        if args.state.rng.d6 > 3
          npc2 = NPC.new(kind, room.center_x + 1, room.center_y, level.depth)
          level.entities << npc2
        end
        if args.state.rng.d6 == 6
          npc3 = NPC.new(kind, room.center_x - 1, room.center_y, level.depth)
          level.entities << npc3
        end
      end
    end
    special_monster_roll = args.state.rng.d20
    if special_monster_roll > 17 && level.depth > 0
      room = level.rooms.sample
      x = room.center_x + Numeric.rand(-1..1)
      y = room.center_y + Numeric.rand(-1..1)
      special = NPC.new(:leprechaun, x, y, level.depth)
      level.entities << special
    end
  end

  def walking_speed # separate to attack speed later
    species_speed = 1.0
    case @species
    when :goblin
      species_speed = 1.2 # seconds per tile
    when :grid_bug
      species_speed = 0.3
    when :rat, :newt, :minotaur
      species_speed = 0.8
    when :gelatinous_cube # these guys keep the dungeon clean??
      species_speed = 5.0
    when :leprechaun
      species_speed = 0.85
    end
    traumatized_speed = species_speed * Trauma.walking_speed_modifier(self)
    status_modifier = 1.0
    if self.has_status?(:speedy)
      status_modifier *= 0.5
    end
    if self.has_status?(:slowed)
      status_modifier *= 2.0
    end
    statuzed_speed = traumatized_speed * status_modifier
    return statuzed_speed
  end

  # THIS IS A KEY METHOD! NPC TAKES ITS TURN HERE
  def take_action args
    behaviour = Behaviour.select_for_npc(self, args)
    printf "NPC #{@species} at (#{@x}, #{@y}) taking action #{behaviour.kind} at time %.2f\n", args.state.kronos.world_time
    behaviour.execute(args) if behaviour
  end

  def title(args)
    "#{@first_name} the #{@species}"
  end

  def generate_first_name
    # TODO: make rnd seeded
    # TODO: move species specific name to sub class
    
    name_parts = [] 
    case @species
    when :goblin
      syllables = [
        "zum", "urg", "arg", "zarg", "nogh", "murs", "ghar", "yrg", "ram", "pat", "myrg", "zy", 
        "za", "gra", "gry", "yrh", "mor", "zug"
      ]
      # Use rand(range) or Random.rand(range)
      length = Numeric.rand(2..3)
      length.times do
        random_index = Numeric.rand(0...syllables.length)
        name_parts << syllables[random_index]
      end
    end

    if name_parts.empty?
      syllables = [
        "ju", "ha", "ni", "jo", "han", "nes", "o", "la", "vi", "an", "te", "ro", 
        "ta", "pa", "mat", "ti", "mik", "ko", "heik", "ki", "sep", "po", "ka", "ri",
        "ma", "ri", "a", "he", "le", "na", "li", "sa", "ee", "va", "pir", "jo", 
        "rit", "va", "tuu", "la", "ai", "no", "lu", "mi", "su", "vi", "hel", "mi", 
        "pih", "la", "va", "na", "mo", "ot", "so", "ha", "vu", "py", "ry", "ki", "vi",
        "väi", "nö", "il", "ma", "ri", "ta", "pi", "o", "tel", "ler", "vo", "sam", "po",
        "kyl", "lik", "ki", "on", "ni", "al", "var", "ven", "la", "lil", "ja", "aa", "da"
      ]
      length = Numeric.rand(2..4)
      length.times do
        random_index = Numeric.rand(0...syllables.length)
        name_parts << syllables[random_index]
      end
    end
    name_parts.join.capitalize
  end

end