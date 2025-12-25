class Item
  attr_accessor :kind, :category, :cursed, :identified, :depth, :x, :y
  attr_reader :attributes, :weight, :traits
  def initialize(kind, category, identified = false)
    @kind = kind
    @category = category
    @cursed = false
    @identified = identified
    @depth = nil
    @x = nil
    @y = nil
    @attributes = []
    @traits = []    
    yield(self) if block_given?
  end

  #footwear and helmet should be included in armor
  def self.categories
    return [:food, :weapon, :potion, :armor, :scroll, :wand, :ring, :scroll, :amulet, :gloves, :footwear, :helmet, :portable_light, :corpse]
  end

  def set_weight # kilograms
    case @category
    when :food
      @weight = 0.4 
    when :weapon
      @weight = 1.0
    when :potion
      @weight = 0.2
    when :armor
      @weight = 4.0
    when :scroll
      @weight = 0.2
    when :wand
      @weight = 0.1
    when :ring
      @weight = 0.02
    when :amulet
      @weight = 0.2
    when :gloves
      @weight = 0.4
    when :footwear
      @weight = 0.4
    when :helmet
      @weight = 0.3
    else
      @weight = 0.4
    end
  end

  def set_weight_in_kilograms  # kilograms
    case @category
    when :food
      @weight = 0.4 
    when :weapon
      @weight = 1.0
    when :potion
      @weight = 0.2
    when :armor
      @weight = 4.0
    when :scroll
      @weight = 0.2
    when :wand
      @weight = 0.1
    when :ring
      @weight = 0.02
    when :amulet
      @weight = 0.2
    when :gloves
      @weight = 0.4
    when :footwear
      @weight = 0.4
    when :helmet
      @weight = 0.3
    else
      @weight = 0.4
    end
  end

  def add_attribute(attribute)
    @attributes << attribute unless @attributes.include?(attribute)
  end

  def remove_attribute(attribute)
    @attributes.delete(attribute)
  end

  def color
    [56, 100, 100]
  end

  def title(args)
    "#{self.attributes.join(' ')} #{self.kind.to_s.gsub('_',' ')}".trim
  end

  def c 
    # character representation from the sprite sheet
    case @category
    when :food
      return [5,2]
    when :weapon
      return [9,2]
    when :potion
      return [1,2]
    when :armor
      return [2,0]
    when :scroll
      return [15,3]
    when :wand
      return [15,2]
    when :ring
      return [13,3]
    when :amulet
      return [15,0]
    when :gloves
      return [7,0]
    when :footwear
      return [8,0]
    when :helmet
      return [9,0]
    when :corpse
      return [5,2]
    when :valuable
      return [10,2]
    when :portable_light
      return [13,10]
    else
      return [1,0] # unknown
    end
  end

  def self.populate_dungeon(dungeon, args)
    for level in dungeon.levels
      self.populate_level(level, args)
    end
  end

  def self.populate_level(level, args)
    level.rooms.each do |room|
      case args.state.rng.d20
        when 1
          item = Food.new(:food_ration, args)
          item.depth = level.depth
          item.x = room.center_x
          item.y = room.center_y
          level.items << item
        when 2
          item = Potion.randomize(level.depth, args)
          item.depth = level.depth
          item.x = room.center_x
          item.y = room.center_y
          level.items << item
        when 3
          if args.state.rng.d20 < level.depth + 5
            item = Ring.new(Ring.kinds.sample)
            item.depth = level.depth
            item.x = room.center_x
            item.y = room.center_y
            level.items << item
          else
            item = Potion.new(:potion_of_healing)
            item.depth = level.depth
            item.x = room.center_x
            item.y = room.center_y
            level.items << item
          end
        when 4
          item = Weapon.randomize(level.depth, args)
          item.x = room.center_x
          item.y = room.center_y
          level.items << item
        when 5
          item = Scroll.randomize(level.depth, args)
          item.depth = level.depth
          item.x = room.center_x
          item.y = room.center_y
          level.items << item
        when 7
          item = Valuable.randomize(level.depth, args)
          item.depth = level.depth
          item.x = room.center_x
          item.y = room.center_y
          level.items << item   
        when 8
          item = Wand.randomize(level.depth, args)
          item.depth = level.depth
          item.x = room.center_x
          item.y = room.center_y
          level.items << item      
        when 9
            puts 'attempting to place armor'
            item = Armor.randomize(level.depth, args)
            item.depth = level.depth
            item.x = room.center_x
            item.y = room.center_y
            level.items << item
      end
    end
  end

  # weight in kilograms
  def self.carried_weight(entity)
    total_weight = 0.0
    if entity.carried_items
      entity.carried_items.each do |item|
        total_weight += item.weight || 0.0
      end
    end
    return total_weight
  end

  # base carrying capacity - how many kilograms can be carried without encumbrance
  # hauling capacity - maximum load that can be carried, only few squares at a time
  def self.base_carrying_capacity(entity)
    base_capacity = 10.0                          
    case entity.species 
    when :dwarf
      base_capacity += 20.0
    when :troll
      base_capacity += 40.0
    when :gnome
      base_capacity -= 5.0
    when :halfling, :goblin, :duck
      base_capacity -= 3.0
    when :dark_elf, :elf
      base_capacity -= 1.0
    end
    return base_capacity
  end

  def self.maximum_carrying_capacity(entity)
    return Item.base_carrying_capacity(entity) * 5.0
  end

  def self.encumbrance_factor(entity, args)
    carrying_capacity = Item.base_carrying_capacity(entity)
    total_weight = Item.carried_weight(entity)
    if total_weight <= carrying_capacity
      return 1.0
    elsif total_weight <= carrying_capacity * 1.5
      return 1.2 # light encumbrance
    elsif total_weight <= carrying_capacity * 2.0
      return 2.0  # medium encumbrance
    elsif total_weight <= carrying_capacity * 3.0
      return 6.0 # heavy encumbrance
    elsif total_weight <= carrying_capacity * 4.0
      return 8.0 # heavy encumbrance
    elsif total_weight <= Item.maximum_carrying_capacity(entity)  
      # heavy encumbrance
      return 12.0
    end
  end

  def use(user, args)
    if self.category == :portable_light
      #wield/unwield the portable light
      if user.wielded_items.include?(self)
        user.wielded_items.delete(self)
        HUD.output_message(args, "#{user.name} puts away the #{self.title(args)}.")
      else
        # imporant that we add it to the end of the list
        user.wielded_items << self
        if user.wielded_items.length > 2
          user.wielded_items = user.wielded_items.slice(1,2)
        end
        HUD.output_message(args, "#{user.name} wields the #{self.title(args)}.")
      end
      Lighting.mark_lighting_stale
      return
    end
  end

  def protects_against_trauma?(kind)
    return false
  end

  def self.setup_items_for_new_hero(hero, args)
    # give starting items
    starting_items = [
      :food_ration,
      :potion_of_healing,
      :bow,
      :torch
    ]
    starting_items.each do |kind|
      item = nil
      case kind
      when :food_ration
        item = Food.new(:food_ration, args)
      when :potion_of_healing
        item = Potion.new(:potion_of_healing)
      when :scroll_of_mapping
        item = Scroll.new(:scroll_of_mapping)
      when :dagger
        item = Weapon.new(:dagger)
      when :bow
        item = Weapon.new(:bow)
      when :torch
        item = PortableLight.new(:torch)
        hero.wielded_items << item
      end
      if item
        hero.carried_items << item
      end
    end
    case hero.role
    when :wizard
      hero.carried_items << Scroll.new(:scroll_of_digging)
      hero.carried_items << Wand.new(Wand.kinds.sample, args)
      hero.carried_items << Wand.new(Wand.kinds.sample, args)
    when :archaeologist
      hero.carried_items << Weapon.new(:whip)
      hero.carried_items << Scroll.new(:scroll_of_mapping)
    when :tourist
      hero.carried_items << Weapon.new(:camera)
      hero.carried_items << Scroll.new(:scroll_of_mapping)
    when :detective
      hero.carried_items << Weapon.new(:revolver)
    when :cleric
      hero.carried_items << Weapon.new(:mace)
      hero.carried_items << Potion.new(:potion_of_extra_healing)
      hero.carried_items << Potion.new(:potion_of_holy_water)
    when :druid
      hero.carried_items << Weapon.new(:staff)
      hero.carried_items << Wand.new(Wand.kinds.sample, args)
      hero.carried_items << Potion.new(Potion.kinds.sample)
      hero.carried_items << Potion.new(Potion.kinds.sample)
    when :monk
      hero.carried_items << Weapon.new(:staff)
      hero.carried_items << Potion.new(:potion_of_extra_healing)
      hero.carried_items << Potion.new(:potion_of_holy_water)
    when :knight
      hero.carried_items << Weapon.new(:sword)
      # plate armour
      hero.worn_items << Armor.new(:plate_armor_shirt)
      hero.worn_items << Armor.new(:plate_armor_pants)
      hero.worn_items << Armor.new(:helmet)
    when :samurai
      Weapon.new(:katana) do |weapon|
        hero.carried_items << weapon
        hero.wielded_items << weapon
      end
      Armor.new(:lamellar_armor_shirt) do |armor|
        hero.carried_items << armor
        hero.worn_items << armor
      end
      Armor.new(:lamellar_armor_pants) do |armor|
        hero.carried_items << armor
        hero.worn_items << armor
      end
      Armor.new(:kabuto) do |armor|
        hero.carried_items << armor
        hero.worn_items << armor
      end 
    when :warrior
      weapon = Weapon.new(:axe)
      hero.carried_items << weapon
      hero.wielded_items << weapon
      # fur shorts
      shorts = Armor.new(:fur_shorts)
      hero.worn_items << shorts 
      hero.carried_items << shorts
    end

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
      end while !level.is_walkable?(x,y) && attempts < max_attempts
      if attempts >= max_attempts
        HUD.output_message(args, "#{self.name} tries to teleport but fails!")
        return
      end
    end
    if level.is_walkable?(x,y)
      self.x = x
      self.y = y
      self.visual_x = x
      self.visual_y = y
      SoundFX.play_sound(:teleport, args)
      GUI.mark_tiles_stale
      Lighting.mark_lighting_stale
      HUD.mark_minimap_stale
    end
  end
end