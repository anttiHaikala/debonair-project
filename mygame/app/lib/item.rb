class Item
  attr_accessor :kind, :category, :cursed, :identified, :depth, :x, :y, :hit_kind, :meta, :inaccuracy_penalty
  attr_reader :attributes, :weight, :traits
  def initialize(kind, category, identified = false)
    @kind = kind
    @category = category
    #shouold cursed be only inside attrbutes?
    @cursed = false
    @identified = identified
    @depth = nil
    @x = nil
    @y = nil
    @traits = []

    #hooks - can be removed if implemented in subcasses but maybe useful for random new items?
    @hit_kind = :blunt if @hit_kind.nil?
    @meta     = {weight: 0.0, price: 0} if @meta.nil?
    @attributes = [] if @attribies.nil?
    @inaccuracy_penalty = 6 if inaccuracy_penalty.nil?

    yield(self) if block_given?
  end

  def is_ranged?
    false
  end

  def is_throwable?
    false
  end
  
  # Smart Finder: Automatically creates the correct subclass instance based on the kind.
  # This simplified logic assumes all subclasses (Armor, Weapon, etc.) now accept (kind, args) in their initialize.
  def self.create_instance(kind, args)
    # Priority registry of subclasses to check for ownership of the 'kind'
    # does not have Light or Valuable yet because they have different initialize signatures
    item_classes = [Armor, Tool, Weapon, Food, Potion, Scroll, Wand, Ring, Corpse]

    target_class = item_classes.find { |klass| klass.respond_to?(:kinds) && klass.kinds.include?(kind) }

    if target_class
      # Uniform Interface: All subclasses now take the same arguments.
      return target_class.new(kind, args)
    else
      # Fallback for generic items without a specialized class.
      puts "Warning: Unknown item kind '#{kind}', created as generic Item."
      return Item.new(kind,  :misc)
    end
  end

  #empty hooks for subclasses to override
  def self.common_attributes;[];end
  def self.rare_attributes;[];end
  def apply_attribute_modifiers(attribute, args);nil;end
  def identify(args);nil;end
  

  # AH: 27.12.2025 notes:
  # footwear and helmet, gloves etc should be included in armor? Or is it for sprite sheet purposes only?
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

  def add_attribute(attribute, args=nil)
    return if attribute.nil?

    case attribute 
      when :rusty
        if @meta[:material] == :organic  
            attribute = :rotten
        elsif @meta[:material] == :glass || @meta[:material] == :syntethic
            attribute = :moldy
        end
      when :moldy, :rotten
      if @meta[:material] == :metal
          attribute = :rusty
      end
    end

    apply_attribute_modifiers(attribute, args)
    @attributes << attribute unless @attributes.include?(attribute)
  end
  
  def remove_attribute(attribute)
    @attributes.delete(attribute)
  end

  def color
    [56, 100, 100]
  end

  def title(args)
    "#{self.attributes.join(' ')} #{self.kind.to_s}".strip.gsub('_',' ').gsub('  ',' ')
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
      return [11,5]
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
    when :tool
      return [8,2]
    # tools and accessories need to be added here  
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
      x_adjustment = args.state.rng.nxt_int(-1,1)
      y_adjustment = args.state.rng.nxt_int(-1,1)
      item_x = room.center_x + x_adjustment
      item_y = room.center_y + y_adjustment
      # only place item if tile is walkable and no other items are there
      next unless level.is_walkable?(item_x, item_y, args)
      next if level.items.any? { |item| item.x == item_x && item.y == item_y }
      case args.state.rng.d20
        when 1
          item = self.randomize(level.depth, Food, args)
          item.depth = level.depth
          item.x = item_x
          item.y = item_y
          level.items << item
        when 2
          item = Potion.randomize(level.depth, args)
          item.depth = level.depth
          item.x = item_x
          item.y = item_y
          level.items << item
        when 3
          if args.state.rng.d20 < level.depth + 5
            item = Ring.new(Ring.kinds.sample)
            item.depth = level.depth
            item.x = item_x
            item.y = item_y
            level.items << item
          else
            item = Potion.new(:potion_of_healing)
            item.depth = level.depth
            item.x = item_x
            item.y = item_y
            level.items << item
          end
        when 4
          item = self.randomize(level.depth, Weapon, args)
          item.x = item_x
          item.y = item_y
          level.items << item
        when 5
          item = Scroll.randomize(level.depth, args)
          item.depth = level.depth
          item.x = item_x
          item.y = item_y
          level.items << item
        when 7
          item = Valuable.randomize(level.depth, args)
          item.depth = level.depth
          item.x = item_x
          item.y = item_y
          level.items << item   
        when 8
          item = Wand.randomize(level.depth, args)
          item.depth = level.depth
          item.x = item_x
          item.y = item_y
          level.items << item
        when 9
            item = self.randomize(level.depth, Tool, args)
            item.depth = level.depth
            item.x = item_x
            item.y = item_y
            level.items << item
        when 10
            item = self.randomize(level.depth, Armor, args)
            item.depth = level.depth
            item.x = item_x
            item.y = item_y
            level.items << item
      end
    end
  end

  # --- MAIN RANDOMIZATION LOGIC ---

  def self.randomize(level_depth, klass, args)
    pool = klass.data
    max_depth = args.state.max_depth || 10
    progress = [(level_depth - 1.0) / ([max_depth - 1.0, 1.0].max), 1.0].min

    # OPTIMIZED SINGLE PASS:
    # 1. Iterate through data once to calculate scaled weight AND cumulative threshold
    running_total = 0.0
    selection_pool = pool.map do |kind, data|
      base_occ = data[:meta][:occurance]
      # Linear scaling for rarity
      adj_occ = base_occ + (1.0 - base_occ) * progress
      running_total += adj_occ
      
      # We store the "running total" as the item's threshold
      if base_occ == 0.0
        { kind: kind, threshold: -1.0 }
      else
        { kind: kind, threshold: running_total }
      end
    end

    # 2. Roll a number based on the final running total
    roll = args.state.rng.nxt_float * running_total

    # 3. Find the first item where our roll is under the threshold
    winner = selection_pool.find { |entry| roll < entry[:threshold] }
    kind = winner ? winner[:kind] : :hat

    # 4. Create the item
    puts "Generated item: #{kind} at level #{level_depth}" 
    item = klass.new(kind,args)
    
    # 5. Roll for Attributes
    common_roll = args.state.rng.d6
    secondary_common_roll = args.state.rng.d8
    rare_roll = args.state.rng.d20
    aSample = nil

    if rare_roll == 20
      rare_attrs = self.rare_attributes
      aSample = rare_attrs[args.state.rng.nxt_int(0, rare_attrs.length - 1)]
      #armor.apply_attribute_modifiers(args, aSample)
      item.add_attribute(aSample, args)
    else
      common_attrs = self.common_attributes
      aSample = common_attrs[args.state.rng.nxt_int(0, common_attrs.length - 1)]

      if common_roll <= 2
        item.add_attribute(aSample,args)
      end

      if secondary_common_roll == 1
        item.add_attribute(aSample, args)
      end
    end
    item
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
    else #total_weight <= Item.maximum_carrying_capacity(entity)  
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

  # Master list for role-based starting loadouts
  # randomization is not using occurance rates currently
  def self.setup_items_for_new_hero(hero, args)
     # 1. Common Starting Items: Every hero starts with a torch (wielded) and a food ration.
    #item = Food.new(:food_ration, args) #you want to pass args here to get spoilage tracking working
    #hero.carried_items << item
    item = Potion.new(:potion_of_healing)
    hero.carried_items << item
    item = PortableLight.new(:torch)
    hero.carried_items << item
    hero.wielded_items << item
 
    # 2. Role-Specific Loadouts
    role_gear = {
      archeologist: [
        { kind: :hat, state: :worn },
        { kind: :whip, state: :wielded },
        { kind: :leather_boots, state: :worn },
        { kind: :scroll_of_mapping },
        { kind: :food_ration },
        *Array.new(args.state.rng.nxt_int(1, 3)) { { kind: args.state.rng.sample(Food.kinds) } }
      ],
      cleric: [
        { kind: :corinthian_helmet, state: :worn },
        { kind: :mace, state: :wielded },
        { kind: :potion_of_extra_healing },
        { kind: :potion_of_holy_water },
        { kind: :chain_mail_shirt, state: :worn },
        { kind: :food_ration }
      ],
      detective: [
        { kind: :hat, state: :worn },
        { kind: :magnifying_glass },
        { kind: :razor_blade, state: :wielded },
        { kind: :revolver },
        { kind: :notebook },
        { kind: :medkit },
        { kind: :food_ration }
      ],
      druid: [
        { kind: :staff, state: :wielded },
        *Array.new(args.state.rng.nxt_int(1, 3)) { { kind: args.state.rng.sample(Potion.kinds) } },
        *Array.new(args.state.rng.nxt_int(1, 3)) { { kind: args.state.rng.sample(Scroll.kinds) } },
        { kind: args.state.rng.sample(Wand.kinds) },
        { kind: :ring_of_regeneration, state: :worn },
        { kind: :food_ration }
      ],
      knight: [
        { kind: :sword, state: :wielded },
        { kind: :armet, state: :worn },
        { kind: :plate_armor_shirt, state: :worn },
        { kind: :plate_mail_pants, state: :worn },
        { kind: :plate_shoes, state: :worn }
      ],
      monk: [
        { kind: :staff, state: :wielded },
        *Array.new(args.state.rng.nxt_int(1, 2)) { { kind: :potion_of_healing } },
        *Array.new(args.state.rng.nxt_int(1, 2)) { { kind: :potion_of_holy_water } },
        *Array.new(args.state.rng.nxt_int(2, 3)) { { kind: args.state.rng.sample(Scroll.kinds) } },
        *Array.new(args.state.rng.nxt_int(2, 3)) { { kind: :food_ration } }
      ],
      ninja: [
        { kind: :dagger, state: :wielded },
        { kind: :shuriken },
        { kind: :ninja_suit, state: :worn },
        { kind: :bow },
        { kind: :potion_of_teleportation },
        { kind: :food_ration }
      ],
      rogue: [
        { kind: :sword, state: :wielded },
        { kind: :bow },
        { kind: :leather_hood, state: :worn },
        { kind: :leather_armor_shirt, state: :worn },
        { kind: args.state.rng.sample(Potion.kinds) },
        { kind: :food_ration }
      ],
      samurai: [
        { kind: :katana, state: :wielded },
        { kind: :bow },
        { kind: :basic_helmet, state: :worn },
        { kind: :lamellar_armor_shirt, state: :worn },
        { kind: :greaves, state: :worn },
        { kind: :food_ration }
      ],
      thief: [
        { kind: :dagger, state: :wielded },
        { kind: :lockpick },
        { kind: :bow },
        { kind: :rope },
        *Array.new(args.state.rng.nxt_int(1, 3)) { { kind: :food_ration } }
      ],
      tourist: [
        { kind: :hat, state: :worn },
        { kind: :sunglasses, state: :worn },
        { kind: :camera },
        { kind: :selfie_stick, state: :wielded },
        *Array.new(args.state.rng.nxt_int(4, 7)) { { kind: args.state.rng.sample(Food.kinds) } }
      ],
      warrior: [
        { kind: :sword, state: :wielded },
        { kind: :fur_shorts, state: :worn },
        { kind: :breastplate, state: :worn },
        { kind: :viking_helmet, state: :worn },
        { kind: :spear },
        { kind: :food_ration }
      ],
      wizard: [
        { kind: :staff, state: :wielded },
        *Array.new(args.state.rng.nxt_int(2, 3)) { { kind: args.state.rng.sample(Wand.kinds) } },
        *Array.new(args.state.rng.nxt_int(1, 2)) { { kind: args.state.rng.sample(Scroll.kinds) } },
        *Array.new(args.state.rng.nxt_int(1, 2)) { { kind: args.state.rng.sample(Ring.kinds) } },
        { kind: args.state.rng.sample(Potion.kinds) },
        { kind: :food_ration }
      ]
    }
    loadout = role_gear[hero.role] || []
    # 3. Add hero.species specific items if needed
    case hero.species
    when :human
      # no modifications
    when :elf
      loadout.each do |entry|
        if entry[:kind] == :sword || entry[:kind] == :mace
          entry[:kind] = :bow
        end
        if entry[:kind] == :food_ration
          entry[:kind] = :lembas
        end
      end 
      loadout.delete(loadout.sample)         
    when :dark_elf
      loadout.each do |entry|
        if entry[:kind] == :sword || entry[:kind] == :mace
          entry[:kind] = :bow
        end
        if Armor.kinds.include?(entry[:kind])
          loadout.delete(entry)
        end
      end
      loadout.delete(loadout.sample)
      loadout.sample << {attribute: :cursed}
      2.times do
        loadout << {kind: Weapon.kinds.sample}
      end
    when :dwarf
      2.times do 
        loadout.delete(loadout.sample)
      end
      loadout << {kind: :pickaxe}
    when :orc
      loadout.each do |entry|
        if Armor.kinds.include?(entry[:kind])
          entry << {attribute: :made_in_Mordor}
        end
      end
    when :goblin
      loadout << {kind: Armor.kinds.sample}
      loadout.sample << {attribute: :cursed}
    when :troll
      loadout.each do |entry|
        if Armor.kinds.include?(entry[:kind])
          loadout.delete(entry)
        end
      end
    when :halfling
      loadout.each do |entry|
        if entry[:kind] == :food_ration
          entry[:kind] = :lembas
        end
      end
      loadout << {kind: Ring.kinds.sample}
    when :gnome
      loadout.each do |entry|
        if Armor.kinds.include?(entry[:kind])
          randRange = args.state.rng.nxt_int(1, 8)
          case randRange
          when 1   
            loadout.delete(entry)
          when 2
            entry << {attribute: :cursed}
          else
            entry << {attribute: :masterwork}
          end  
        end
      end
      loadout.sample << {attribute: :cursed}

    when :duck
      loadout.each do |entry|
        if entry[:kind] == :food_ration
          entry[:kind] = :bird_food
        end
      end
      loadout.sample << {attribute: :enchanted}
    end

    # 4. Trait specific item modifications
    hero.traits.each do |heroTrait|
      case heroTrait
      when :normal
        # no effect
      when :alien
        4.times do
          loadout.delete(loadout.sample)
        end
        loadout << {kind: :raygun, state: :wielded}
      when :angel
        loadout = []
        loadout << {kind: :wings}
        loadout << {kind: Weapon.kinds.sample, attribute: :holy}
      when :cyborg
        loadout.each do |entry|
          if Weapon.kinds.include?(entry[:kind])
            loadout.delete(entry)
          end
        end 
        loadout << {kind: :cyborg_blade, state: :wielded}
        loadout << {kind: :cyborg_blade, state: :wielded}
      when :demon
        loadout = []
        loadout << {kind: :wings}
        loadout << {kind: :trident}
      when :mutant
        armorFound = false
        loadout.each do |entry|
          if Armor.kinds.include?(entry[:kind])
            loadout.delete(entry)
            armorFound = true
          end
        end
        if armorFound
          loadout << {kind: :silly_stocking_suit, state: :worn}
        else
          loadout << {kind: :silly_stocking_suit, state: :worn, attribute: :cursed}
        end
      when :undead
        loadout.each do |entry|
          if Food.kinds.include?(entry[:kind])
            loadout.delete(entry)
          end
        end
        3.times do
          loadout.sample << {attribute: :cursed}
        end
        if hero.role == :archeologist && hero.species == :dark_elf
          loadout << {kind: :bone_whip_of_death, state: :wielded}
        end
      when :robot
        loadout = []
        loadout << {kind: :battery_pack}
      when :vampire
        puts Food.kinds
        puts loadout
        loadout.each do |entry|
          puts entry[:kind]
          if Food.kinds.include?(entry[:kind])
            entry[:kind] = :blood_pack
          end
        end
      when :werewolf
        # no specific items?
      when :zombie
          loadout.each do |entry|
          if Food.kinds.include?(entry[:kind])
            entry[:kind] = :brain
          end
        end
        3.times do
          # make these later rotten etc - need changes in add_attribute
          loadout.sample << {attribute: :broken}
        end      
      end
    end

  # 5. Age specific item modifications
    case hero.age
    when :teen
      loadout.each do |entry|
        if entry[:kind] == :food_ration
          entry[:kind] = :hamburger
        end
        if Scroll.kinds.include?(entry[:kind])
          entry[:kind] = :potion_of_speed
        end
      end
    when :adult
      # no effect
    when :elder
      noWeapon = true
      loadout.each do |entry|
        if Weapon.kinds.include?(entry[:kind])
          noWeapon = false
        end
        entry << {identified: true}
      end
      2.times do
        loadout.delete(loadout.sample)
        #maybe identified object are alraedy good enough
        #loadout << {kind: Scroll.kinds.sample, identified: true}
      end
      if noWeapon
        loadout << {kind: :staff, state: :wielded}
      end
    end

    # 6. Apply random luck modifications
    luckRoll = args.state.rng.nxt_int(1, 100)
    allItems = Weapon.kinds + Armor.kinds + Potion.kinds + Scroll.kinds + Ring.kinds + Wand.kinds + Food.kinds
    if luckRoll <= 5
      loadout.delete(loadout.sample)
      HUD.output_message(args, "You might have forgotten something...")
    elsif luckRoll >= 90
      loadout << {kind: allItems.sample}
      HUD.output_message(args, "This might be a good day after all...")
    elsif luckRoll == 100
      3.times do
        loadout << {kind: allItems.sample, attribute: :enchanted}
        HUD.output_message(args, "You feel lucky today!")
      end
    end

    # Apply the Loadout
    loadout.each do |entry|
      # Handle count for multi-item drops or random counts
      # Count not used in item generation atm
      repeat = entry[:count] || 1
      repeat.times do
        kind = entry[:kind]
        identified = entry[:identified] || false
        item = self.create_instance(kind, args)
        item.add_attribute(entry[:attribute],args)
        
        if identified
          item.identify(args)
        end
        hero.carried_items << item
        hero.worn_items << item if entry[:state] == :worn
        hero.wielded_items << item if entry[:state] == :wielded
      end
    end
  end

  def return_pool_item(pool)
    args.state.rng.sample(pool)
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
    if level.is_walkable?(x, y, args)
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