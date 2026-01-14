class Hero < Entity

  include Needy

  attr_reader :trait, :name, :exhaustion, :sleep_deprivation, :insanity, :carried_items, :max_depth
  attr_accessor :role, :species, :age, :hunger, :hunger_level, :stress, :perished, :reason_of_death, :known_potions, :known_scrolls, :known_wands, :known_rings

  def initialize(age, trait, species, role)
    super(nil, nil) # we don't know the location yet 
    initialize_needs
    @kind = :pc
    @role = role
    @species = species
    @traits = [trait]
    @age = age
    @name = random_name
    @exhaustion = 0.2 # 0.0 = totally rested, 1.0 = totally exhausted
    @hunger = 0.2 # 0.0 = satiated, 1.0 = starving
    @hunger_level = :okay
    @sleep_deprivation = 0.2 # 0.0 = well-rested, 1.0 = totally sleep-deprived
    @insanity = 0.0 # 0.0 = sane, 1.0 = totally insane
    @stress = 0.0 # 0.0 = calm, 1.0 = totally stressed
    @max_depth = 0
    @known_potions = []
    @known_scrolls = []
    @known_rings = []
    @known_wands = []
  end

  # modifies a d20 roll to resist theft attempts
  def anti_steal_ability
    modifier = 0
    case self.role
    when :thief
      modifier += 5
    when :ninja
      modifier += 3
    when :detective
      modifier += 2
    when :rogue
      modifier += 1
    when :warrior, :samurai, :knight
      modifier -= 2
    when :tourist
      modifier -= 4
    end
    case self.trait
    when :undead
      modifier -= 3
    when :zombie
      modifier -= 4
    end
    case self.species
    when :elf, :dark_elf, :gnome
      modifier += 1
    when :orc
      modifier -= 1
    when :troll
      modifier -= 2
    end
    return modifier
  end

  def self.roles
    [
      :archeologist, # maps and artifacts
      :cleric, # holiness
      :detective, # investigation and clues
      :druid, # spells and nature
      :wizard, # classic spellcaster
      :monk, # martial arts and spirituality
      :ninja, # stealth and combat
      :rogue, # agility and trickery
      :samurai, # combat and honor
      :knight, # combat and chivalry and plate mail
      :thief, # stealth and deception
      :tourist, # camera and confidence
      :warrior, # strength and bravery
    ]
  end

  def self.species
    [
      :human,
      :elf,
      :dark_elf,
      :duck, # glorantha style
      :dwarf,
      :gnome,
      :goblin,
      :halfling,
      :orc,
      :troll,
    ]
  end

  def self.age
    [
      :adult,
      :elder,
      :teen
    ]
  end

  def self.traits
    [
      :normal,
      :alien,
      :angel,
      :cyborg,      
      :demon,
      :mutant,
      :undead,
      :robot,
      :vampire,
      :werewolf,
      :zombie
    ]
  end

  def trait
    return @traits[0]
  end

  def hue
    0
  end

  def random_name
    names = ['Jaakko', 'Liisa', 'Mikko', 'Anna', 'Kari', 'Sari', 'Pekka', 'Marja', 'Jukka', 'Tiina', 'Marjatta', 'Antti', 'Kaisa', 'Jari', 'Laura', 'Timo', 'Sanna', 'Markku', 'Katja', 'Juha', 'Virpi', 'Minerva', 'Ener', 'Aapo', 'Aila', 'Aino', 'Alarik', 'Aleksi', 'Aliisa', 'Alpo', 'Anja', 'Armas', 'Arto', 'Aune', 'Eero', 'Elina', 'Eljas', 'Emmi', 'Esko', 'Helmi', 'Hilkka', 'Ilmari', 'Inkeri', 'Irma', 'Jalmari', 'Kaarina', 'Kalevi', 'Leena', 'Lempi', 'Lempiina', 'Lauri', 'Levi', 'Liisi', 'Lyyli', 'Maija', 'Malla', 'Martti', 'Matias', 'Onni', 'Orvokki', 'Outi', 'Paavo', 'Pirkko', 'Reino', 'Ritva','Jari-Pekka']
    return names.sample
  end

  def set_depth(depth, args)
    @depth = depth
    if depth > @max_depth
      @max_depth = depth
    end
  end

  def color # hsl
    return [255, 0, 255]
  end

  def vision_range
    range = 112
    if @age == :elder
      range -= 5
    end
    if @species == :dwarf || @species == :gnome
      range -= 4
    end
    if @species == :elf || @species == :dark_elf
      range += 4
    end
    return range
  end

  def walking_speed
    seconds_per_tile = 1.0
    if @age == :elder
      seconds_per_tile += 0.4
    end
    if self.has_trait?(:zombie)
      seconds_per_tile += 0.4
    end
    if @trait == :robot
      seconds_per_tile += 0.1
    end
    if @trait == :cyborg 
      seconds_per_tile -= 0.1
    end
    if @species == :duck
      seconds_per_tile += 0.2
    end
    if @species == :elf || @species == :dark_elf
      seconds_per_tile -= 0.2
    end
    if @role == :ninja || @role == :thief
      seconds_per_tile -= 0.2
    end
    traumatized_speed = seconds_per_tile / Trauma.walking_speed_modifier(self)
    if self.has_status?(:speedy)
      status_modifier = 0.5
    else
      status_modifier = 1.0
    end
    if self.has_status?(:slowed)
      status_modifier *= 2.0
    end
    statuzed_speed = traumatized_speed * status_modifier
    return statuzed_speed
  end

  def mental_speed
    seconds_per_thought = 1.0
    if @age == :elder
      seconds_per_thought += 0.5
    end
    if @trait == :robot
      seconds_per_thought -= 0.2
    end
    if @trait == :cyborg 
      seconds_per_thought -= 0.1
    end
    if @role == :mage || @role == :detective
      seconds_per_thought -= 0.3
    end
    return seconds_per_thought
  end


  def pickup_speed
    seconds_per_pickup = 1.0 # seconds to pick up items
    if @species == :halfling || @species == :gnome
      seconds_per_pickup -= 0.3
    end
    return seconds_per_pickup
  end

  def rest(args)
    args.state.kronos.spend_time(self, 1.0, args)
    apply_exhaustion(-0.05, args)
    self.detect_traps(args)
    self.detect_secret_doors(args)
  end

  def stealth_range
    range = 10 # smaller is stealthier
    if @role == :ninja || @role == :thief
      range -= 3
    end
    if @species == :halfling || @species == :gnome
      range -= 3
    end
    return range
  end

  def c
    [0, 4]
  end

  def take_action args
    # hero is controlled by player, so no AI here
  end 

  def behaviour
    nil
  end

  def pick_up_item(item, level, args)
    @carried_items << item
    level.items.delete(item)
    item.x = nil
    item.y = nil
    item.depth = nil
    printf "Picked up item: %s\n" % item.kind.to_s
    SoundFX.play_sound("pickup_#{item.category}", args)
    HUD.output_message(args, "You picked up #{item.title(args)}.")
    if item.kind == :amulet_of_skandor
      args.state.architect.setup_endgame(args)
      HUD.output_message(args, "Your intuition tells you things might get more difficult now.")
    end
  end

  def has_item?(item_kind)
    @carried_items.each do |item|
      return true if item.kind == item_kind
    end
    return false
  end

  def apply_exhaustion (amount, args)
    previous_exhaustion = @exhaustion
    @exhaustion += amount
    @exhaustion = 0.0 if @exhaustion < 0.0
    @exhaustion = 1.0 if @exhaustion > 1.0
    if @exhaustion > 0.6 && previous_exhaustion <= 0.6
      HUD.output_message(args, "You feel somewhat exhausted.")
    end
    if @exhaustion > 0.8 && previous_exhaustion <= 0.8
      HUD.output_message(args, "You feel proper exhausted.")
    end
    if @exhaustion > 0.9 && previous_exhaustion <= 0.9
      HUD.output_message(args, "You feel super exhausted, you really need to rest soon.")
    end
    if @exhaustion < 0.6 && previous_exhaustion >= 0.6
      HUD.output_message(args, "You feel somewhat rested.")
    end
    if @exhaustion < 0.4 && previous_exhaustion >= 0.4
      HUD.output_message(args, "You feel rested.")
    end
    if @exhaustion < 0.1 && previous_exhaustion >= 0.1
      HUD.output_message(args, "You feel well rested.")
    end
  end
  
  def apply_hunger args
    hero = self
    hunger_increase = 0.001 # per game world time unit
    @hunger += hunger_increase
    hunger_level_before = @hunger_level
    if @hunger >= 1.0
      @hunger_level = :dying
    elsif @hunger >= 0.8
      @hunger_level = :starving
    elsif @hunger >= 0.5
      @hunger_level = :hungry
    elsif @hunger >= 0.2
      @hunger_level = :okay
    else
      @hunger_level = :satiated
    end
    if @hunger > 0.9
      HUD.output_message(args, "Eat soon or you will die from hunger.")
    end
    if hunger_level_before != @hunger_level
      case @hunger_level
      when :satiated
        if hero.traits.include?(:robot) || hero.traits.include?(:undead)
          HUD.output_message(args, "You feel full of energy.")
        else
          HUD.output_message(args, "You feel satiated.")
        end
      when :okay
        if !hunger_level_before == :satiated
          if hero.traits.include?(:robot) || hero.traits.include?(:undead)
            HUD.output_message(args, "You no longer lack energy.")
          else
            HUD.output_message(args, "You are no longer hungry.")
          end
        end
      when :hungry
        if hero.traits.include?(:robot) || hero.traits.include?(:undead)
          HUD.output_message(args, "You are somewhat low on energy.")
        else
          HUD.output_message(args, "You feel hungry.")
        end 
      when :starving
        if hero.traits.include?(:robot) || hero.traits.include?(:undead)
          HUD.output_message(args, "You are low on energy!")
        else
          HUD.output_message(args, "You feel starving!")
        end
      when :dying
        if hero.traits.include?(:undead) || hero.traits.include?(:robot)
          HUD.output_message(args, "You have no energy left. Eat something.")
        else
          HUD.output_message(args, "You starve to death!")
          args.state.hero.perished = true
          args.state.hero.reason_of_death = "of starvation"
        end
      end
    end      
  end

  def apply_walking_exhaustion args
    base_exhaustion_increase = 0.002 # per tile walked
    exhaustion_increase = base_exhaustion_increase * Item.encumbrance_factor(self, args) 
    if self.traits.include?(:robot)
      exhaustion_increase *= 0.5
    end
    apply_exhaustion(exhaustion_increase, args)
  end

  def walking_sound tile, args
    if tile == :water
      SoundFX.play_sound(:water_walk, args, 0.5)
    else
      SoundFX.play_sound(:walk, args, 0.5)
    end
  end

  # how good the character is at detecting traps, secret doors and hidden furnitureb
  def detection_modifier
    modifier = 0
    case self.role
    when :detective
      modifier += 0.4
    when :archeologist
      modifier += 0.3
    when :thief, :ninja
      modifier += 0.2
    when :warrior, :tourist, :knight
      modifier -= 0.1
    end
    case self.species
    when :elf, :dark_elf, :halfling, :gnome
      modifier += 0.1
    end
    [:undead, :zombie, :robot].each do |trait|
      if self.traits.include?(trait)
        modifier -= 0.2
      end
    end
    return modifier
  end
  
  def detect_secret_doors args
    level = Utils.level(args)
    detection_range = 2
    level.furniture.each do |furniture|
      next unless furniture.kind == :secret_door
      distance = Utils.distance_between_entities(self, furniture)
      if distance <= detection_range && Tile.is_tile_visible?(furniture.x, furniture.y, args)
        if !furniture.seen_by_hero
          printf "Checking for secret door detection at furniture location (%d,%d)\n" % [furniture.x, furniture.y]
          # odds to detect secret door depend on role, species, lighting, etc.
          lighting_modifier = Lighting.light_level_at(furniture.x, furniture.y, level, args) 
          printf "Secret door detection lighting modifier: %.2f\n" % lighting_modifier
          base_detection_chance = 0.33333 
          base_detection_chance += self.detection_modifier
          base_detection_chance *= lighting_modifier
          final_detection_chance = base_detection_chance * 0.03 # player has infinite attempts, so lower the odds
          printf "Final secret door detection chance: %.2f\n" % final_detection_chance
          detection_roll = args.state.rng.nxt_float
          if detection_roll < final_detection_chance
            HUD.output_message(args, "You notice something unusual about a section of the wall...")
            furniture.seen_by_hero = true
            SoundFX.play_sound(:clue, args)
            GUI.add_input_cooldown(30)
          end
        end
      end
    end
  end

  def detect_traps args
    level = Utils.level(args)
    detection_range = 2
    level.traps.each do |trap|
      distance = Utils.distance_between_entities(self, trap)
      if distance <= detection_range && Tile.is_tile_visible?(trap.x, trap.y, args)
        if !trap.found
          printf "Checking for trap detection at trap location (%d,%d)\n" % [trap.x, trap.y]
          # odds to detect trap depend on role, species, lighting, etc.
          lighting_modifier = Lighting.light_level_at(trap.x, trap.y, level, args) 
          printf "Trap detection lighting modifier: %.2f\n" % lighting_modifier
          base_detection_chance = 0.33333
          base_detection_chance += self.detection_modifier
          base_detection_chance *= lighting_modifier
          final_detection_chance = base_detection_chance * 0.1
          printf "Final trap detection chance: %.2f\n" % final_detection_chance
          detection_roll = args.state.rng.nxt_float
          if detection_roll < final_detection_chance
            HUD.output_message(args, "You detect a #{trap.kind.to_s.gsub('_',' ')} trap nearby!")
            trap.found = true
            SoundFX.play_sound(:clue, args)
            GUI.add_input_cooldown(30)
          end
          if self.worn_items.include?(:ring_of_warning)
            if args.state.rng.d6 == 1
              HUD.output_message(args, "Your ring of warning tingles!")
              trap.found = true
              SoundFX.play_sound(:trap_detected, args)
            end
          end
        end
      end
    end
  end

  def strength_modifier
    strength = 0
    case self.role
    when :warrior, :samurai, :knight
      strength += 3
    when :ninja, :rogue
      strength += 1
    when :thief, :detective, :monk
      strength -= 1
    when :wizard, :tourist
      strength -= 3
    end
    case self.species
    when :orc, :troll
      strength += 2
    when :dwarf
      strength += 1
    when :elf, :dark_elf, :duck, :gnome
      strength -= 1
    when :halfling
      strength -= 2
    end
    return strength    
  end

end