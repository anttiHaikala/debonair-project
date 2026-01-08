class Entity
  # x and y are the logical positions in the grid
  # visual_x and visual_y are used for smooth movement animations
  attr_accessor :depth, :x, :y, :kind, :visual_x, :visual_y, :busy_until, :traumas, :perished, :reason_of_death, :species

  attr_accessor :enemies
  attr_accessor :allies
  attr_accessor :needs
  attr_accessor :carried_items # all items that are carried (inventory)
  attr_accessor :worn_items # items that are worn (armor, rings, amulets, etc.)
  attr_accessor :wielded_items   # hand index: 0 = right hand, 1 = left hand, if multiple sets of hands, start from the top
  attr_accessor :behaviours
  attr_accessor :statuses
  attr_accessor :traits
  attr_accessor :hands
  attr_accessor :facing # :south, :north, :east, :west
  attr_accessor :mode_of_movement
  attr_accessor :feels
  attr_accessor :feel_cooldown
  attr_accessor :last_behaviour
  attr_accessor :handedness # :right, :left, :ambidextrous

  def self.kinds
    [:generic, :item, :pc, :npc, :plant, :furniture]
  end

  def initialize(x, y, kind = :generic)
    @x = x
    @y = y
    @kind = kind # item, pc, npc, etc.
    @visual_x = x
    @visual_y = y
    @traumas = []
    @enemies = []
    @allies = []
    @needs = []
    @perished = false
    @reason_of_death = nil
    @carried_items = [] # worn and wielded items are also included in this list
    @worn_items = []
    @wielded_items = []
    @behaviours = []
    @statuses = []
    @traits = []
    @feels = []
    @hands = [:right, :left] # in order of preference
    @facing = :west
    @mode_of_movement = :normal # :sneaking, :walking, :speeding
    @feel_cooldown = 0
    @handedness = :right
  end

  def all_items(args)
    return @carried_items + @worn_items + @wielded_items
  end

  def is_hostile_to?(other_entity)
    return @enemies.include?(other_entity)
  end

  def become_hostile_to(other_entity)
    @enemies << other_entity unless @enemies.include?(other_entity)
  end
    
  def is_allied_to?(other_entity)
    return @allies.include?(other_entity)
  end

  # returns true if other_entity is in one of the four adjacent tiles
  def adjacent_to?(other_entity)
    return Utils.adjacent?(self.x, self.y, other_entity.x, other_entity.y)
  end

  def add_status(status)
    @statuses << status unless @statuses.include?(status)
  end

  # this utility method returns only the actual wielded items, without nils
  def wielded
    return @wielded_items.compact
  end

  # eats both status objects and kind symbols
  def remove_status(status)
    @statuses.delete(status) if @statuses.include?(status)
    @statuses.each do |s|
      if s.kind == status
        @statuses.delete(s)
      end
    end
  end

  def has_status?(kind)
    @statuses.each do |status|
      if status.kind == kind
        return true
      end
    end
    return false
  end
  
  def color
    return [255, 255, 255]
  end

  def random_body_part(args)
    parts = body_parts
    parts[args.state.rng.rand(parts.length)]
  end

  def title args
    self.name
  end

  def in_a_pit?(args)
    # if not levitating and standing on a pit furniture
    levitating = self.has_status?(:levitating)
    there_is_a_pit = Furniture.furniture_at(self.x, self.y, args.state.dungeon.levels[self.depth], args)&.kind == :pit
    return !levitating && there_is_a_pit
  end

  # todo: more fleshed out mechanics (consider character size, strength, agility and wounds)
  # now we have a super simple mechanism here
  def climb_out_of_pit(args)
    roll = args.state.rng.d6
    if roll > 4
      return true
    else
      return false
    end
  end
    
  def body_parts
    case @species
    when :grid_bug
      return Species.bug_body_parts
    when :rat
      return Species.mammal_body_parts
    else
      return Species.humanoid_hit_locations
    end
  end

  def telepathy_range
    range = 0
    case @species
    when :grid_bug
      range += 5
    end
    self.traits.each do |trait|
      case trait
      when :alien
        range += 5 # aliens have a mild telepathy built in
      end
    end
    if self.worn_items
      self.worn_items.each do |item|
        if item.kind == :ring_of_telepathy
          range += 16
        end
      end
    end
    if self.has_status?(:telepathic)
      range += 20
    end
    return range
  end

  def invisible?
    invisibility = false
    if self.worn_items
      self.worn_items.each do |item|
        if item.kind == :cloak_of_invisibility || item.kind == :ring_of_invisibility
          invisibility = true
        end
      end
    end
    if self.has_status?(:invisible)
      invisibility = true
    end
    return invisibility
  end

  def sees?(other_entity, args)
    able_to_see = true
    if other_entity.invisible?
      able_to_see = false
    end
    if !Utils.line_of_sight?(self.x, self.y, other_entity.x, other_entity.y, args.state.dungeon.levels[self.depth])
      able_to_see = false
    end
    
    return able_to_see
  end

  def use_item(item, args)
    # check that entity has item
    unless self.carried_items && self.carried_items.include?(item)
      printf "ERROR: #{self.name} tries to use a #{item.kind.to_s.gsub('_',' ')} but doesn't have it."
      return
    end
    item.use(self, args)
  end

  def drop_item(item, args)
    # check that entity has item
    unless self.carried_items && self.carried_items.include?(item)
      printf "ERROR: #{self.name} tries to drop a #{item.kind.to_s.gsub('_',' ')} but doesn't have it."
      return
    end
    if self.wielded_items && self.wielded_items.include?(item)
      self.wielded_items.delete(item)
    end
    self.carried_items.delete(item)
    level = args.state.dungeon.levels[self.depth]
    item.x = self.x
    item.y = self.y
    item.depth = self.depth
    level.items << item
    printf "Dropped item: %s\n" % item.kind.to_s
    SoundFX.play_sound(:drop_item, args)
    HUD.output_message(args, "#{self.name} dropped #{item.title(args)}.")
  end

  def teleport(args, x=nil, y=nil)
    level = args.state.dungeon.levels[self.depth]
    if x.nil? || y.nil?
      # random teleport
      max_attempts = 100
      attempts = 0
      begin
        x = args.state.rng.nxt_int(0, level.width-1)
        y = args.state.rng.nxt_int(0, level.height-1)
        attempts += 1
        printf "Teleport attempt %d to (%d, %d)\n" % [attempts, x, y]
      end while !level.is_walkable?(x, y, args) && attempts < max_attempts
      if attempts >= max_attempts
        HUD.output_message(args, "#{self.name} tries to teleport but fails!")
        return
      end
    end
    if level.is_walkable?(x, y, args)
      self.set_location(x, y)
      SoundFX.play_sound(:teleport, args)
      GUI.mark_tiles_stale
      Tile.observe_tiles args
      Lighting.mark_lighting_stale
      HUD.mark_minimap_stale
      Lighting.calculate_lighting(level, args)
    end
  end

  def set_location(x, y)
    self.x = x
    self.y = y
    self.visual_x = x
    self.visual_y = y
  end

  def slowed_in_water?
    slowed = true
    if self.species == :grid_bug
      slowed = false
    end
    return slowed
  end 

  def walking_sound tile, args
    return
  end

  def drop_wielded_items(args)
    if self.wielded && self.wielded.length > 0
      self.wielded.each do |item|
        self.drop_item(item, args)
      end
    end 
  end

  def drop_all_items(args)
    if self.carried_items
      self.carried_items.each do |item|
        HUD.output_message(args, "#{self.name} drops #{item.title(args)}.")
        level = args.state.dungeon.levels[self.depth]
        item.x = self.x
        item.y = self.y
        item.depth = self.depth
        level.items << item
      end
      self.carried_items = []
    end
  end

  def perish(args)
    @perished = true
    level = Utils.level_by_depth(self.depth, args) # monsters should probably keep knowledge of their
    self.drop_all_items(args)
    if self.undead?
      HUD.output_message(args, "#{self.name.capitalize} is destroyed!")
    else
      kind = (self.species.to_s + "_corpse").to_sym
      corpse = Item.new(kind, :corpse)
      corpse.depth = self.depth
      corpse.x = self.x
      corpse.y = self.y
      level.items << corpse
      HUD.output_message(args, "#{self.name.capitalize} has perished!")
    end
    level.entities.delete(self)
    if self == args.state.hero
      args.state.game_over = true
    end
  end

  # hand index: 0 = right hand, 1 = left hand, if multiple sets of hands, start from the top
  def wield_item(item, hand_index, args)
    # remove from other hand if already wielded there
    self.wielded_items.each_with_index do |wielded_item, index|
      if wielded_item == item
        self.wielded_items.delete_at(index)
      end
    end
    # ensure enough hands
    while self.wielded_items.length <= hand_index
      self.wielded_items << nil
    end
    # wield
    self.wielded_items[hand_index] = item
  end

  def wield_info(item)
    self.wielded_items.each_with_index do |wielded_item, index|
      if wielded_item == item
        if index == 0
          return "(in right hand)"
        elsif index == 1
          return "(in left hand)"
        end
      end
    end
    return ""
  end
  def undead?
    return Species.undead_species.include?(self.species)
  end

  def recover_shock(args)
    # default: do nothing
    if self.has_status?(:shocked)
      if args.state.rng.d20 == 20
        # recover some shock over time
        self.remove_status(:shocked)
        HUD.output_message(args, "#{self.name} recovers from shock.")
      end
    end
  end

  def has_trait?(trait)
    return self.traits.include?(trait)
  end

  #should this be moved to combat instead?
  def natural_attack(args=nil)
    # make species specific damage types later
    return :blunt
  end

  def apply_new_facing(facing)
    @facing = facing
  end

  def set_depth(new_depth, args)
    @depth = new_depth
  end

  def feel(feeling, args)
    #@feels << feeling unless @feels.include?(feeling)
    @feels = [feeling]
    @feel_cooldown = args.state.kronos.world_time + 10
    printf "%s feels %s until %d\n" % [self.name.capitalize, feeling.to_s, @feel_cooldown] 
  end

  def is_wearing?(item)
    return self.worn_items.include?(item)
  end

  def is_wielding?(item)
    return self.wielded_items.include?(item)
  end

  # returns the currently equipped weapon or a default unarmed attack
  def equipped_weapon
    self.wielded_items.each do |item|
      if item.category == :weapon
        return item # right hand has priority because it is first in the list
      end
    end
    return Weapon.new(:fist) # TODO: make kick and push available as well 
  end

end