class Ring < Item
  # DATA contains metadata and usage configuration
  # occurance is set to 1.0 and weight to 0.01 across all types
  DATA = {
    ring_of_endurance:       { meta: { occurance: 1.0, weight: 0.01, price: 100 }, max_usage: 1000 },
    ring_of_fire_resistance: { meta: { occurance: 1.0, weight: 0.01, price: 150 }, max_usage: 1200 },
    ring_of_cold_resistance: { meta: { occurance: 1.0, weight: 0.01, price: 150 }, max_usage: 1200 },
    ring_of_invisibility:    { meta: { occurance: 0.5, weight: 0.01, price: 500 }, max_usage: 500  },
    ring_of_protection:      { meta: { occurance: 0.5, weight: 0.01, price: 200 }, max_usage: 1500 },
    ring_of_strength:        { meta: { occurance: 1.0, weight: 0.01, price: 250 }, max_usage: 1000 },
    ring_of_illumination:    { meta: { occurance: 1.0, weight: 0.01, price: 80  }, max_usage: 2000 },
    ring_of_regeneration:    { meta: { occurance: 0.2, weight: 0.01, price: 600 }, max_usage: 800  },
    ring_of_teleportation:   { meta: { occurance: 1.0, weight: 0.01, price: 300 }, max_usage: 1000 },
    ring_of_accuracy:        { meta: { occurance: 1.0, weight: 0.01, price: 180 }, max_usage: 1500 },
    ring_of_warning:         { meta: { occurance: 1.0, weight: 0.01, price: 400 }, max_usage: 1200 },
    ring_of_telepathy:       { meta: { occurance: 1.0, weight: 0.01, price: 450 }, max_usage: 700  }
  }

  # implement these later 
  # :ring_of_night_vision,
  # :ring_of_adornment,
  # :ring_of_stealth, 

  attr_accessor :kind, :max_usage, :cursed, :meta, :description, :usage

    def initialize(kind, args=nil, &block)
    @kind = kind
    #@attributes = attributes || []
    @usage = 0
    
    blueprint = DATA[kind] || { meta: { occurance: 1.0, weight: 0.01, price: 100 }, max_usage: 1000 }
    # TODO seed for rand?
    @max_usage = blueprint[:max_usage] + Numeric.rand(1..1000) #+ args.state.rng.rand(1..1000)
    @meta =  blueprint[:meta].dup
    @description = "a ring wearable on any finger as long as you don't lose them in combat"
    @weight      = @meta[:weight]      
    @price       = @meta[:price]       
    @occurance  = @meta[:occurance] 
    @usage = 0  
    
    # Logic from original class: 1 in 6 chance to be cursed. TODO: make rand seeded
    # maybe remove the attribute and add cursed to attributes list
    @cursed = (Numeric.rand(1..6) == 1)
    super(kind, :ring, &block)
  end

  #are these used?
  def self.traits
    return [
      :heavy, :lightweight, :ornate, :engraved
    ]
  end

  # --- CLASS DATA ACCESS ---
  def self.data; DATA; end
  def self.kinds; DATA.keys; end

  def self.mask_pool
    [
      :sapphire, :emerald, :ruby, :diamond, :onyx, :topaz, 
      :amethyst, :garnet, :opal, :turquoise, :quartz, :jade, :pearl
    ]
  end

  # Setup masks by shuffling the available list into the game state
  def self.setup_masks(args)
    self.mask_pool.shuffle
  end

  def self.masks(args)
    args.state.run.ring_masks
  end

  def self.randomize(level_depth, args)
    Item.randomize(level_depth, self, args)
  end

  def identify(args)
    unless args.state.hero.known_rings.include?(self.kind)
      args.state.hero.known_rings << self.kind
    end
  end

  def title(args)
    mask_index = self.class.kinds.index(self.kind) % self.class.masks(args).length
    mask = self.class.masks(args)[mask_index]
    if args.state.hero.known_rings.include?(self.kind)
      "#{self.attributes.join(' ')} #{mask} ring (#{self.kind.to_s.gsub('ring_of_','')})".strip
    else
      "#{mask} ring".strip
    end
  end

  def name(args)
    # Fetch the shuffled mask pool from the specific path provided
    mask_pool = args.state.run.ring_masks || self.class.masks
    
    kind_idx = self.class.kinds.index(@kind) || 0
    mask_index = kind_idx % mask_pool.length
    mask = mask_pool[mask_index]
    
    "#{@attributes.join(' ')} #{mask} ring (#{@kind.to_s.gsub('_', ' ')})".strip
  end

   def use(entity, args)
    # TODO: check that we have enough fingers free to wear the ring
    # TODO: maybe have a dexterity penalty if too many rings are being worn!!!
    if entity.worn_items.include?(self)
      if self.cursed
        HUD.output_message(args, "The #{self.kind.to_s.gsub('_',' ')} appears to be stuck to your finger!")
        return
      end
      HUD.output_message(args, "You remove the #{self.kind.to_s.gsub('_',' ')}.")
      entity.worn_items.delete(self)
    else
      entity.worn_items << self
      suffix = ""
      case self.kind
      when :ring_of_illumination
        suffix = " It lights up the area around you."
        SoundFX.play(:illumination, args)
      when :ring_of_invisibility
        suffix = " You become invisible!"
        SoundFX.play(:invisibility, args)
      when :ring_of_telepathy
        suffix = " You feel connected to other minds."
        SoundFX.play(:telepathy, args)
      end
      HUD.output_message(args, "You wear the #{self.kind.to_s.gsub('_',' ')}. " + suffix)
    end
  end

  def apply_continuous_effect(entity, args)
    case self.kind
    when :ring_of_teleportation
      roll_one = args.state.rng.d20
      if roll_one == 1
        roll_two = args.state.rng.d20
        if roll_two >= 15
          HUD.output_message(args, "The #{self.kind.to_s.gsub('_',' ')} glows brightly!")
          entity.teleport(args)
        end
      end
    when :ring_of_regeneration
      Trauma.active_traumas(entity).each do |trauma|
        if self.usage % 10 == 0 # heal one step every 10 usage ticks
          roll = args.state.rng.d12
          if roll >= trauma.numeric_severity
            HUD.output_message(args, "#{trauma.title(args)} gets better.")
            trauma.heal_one_step
            break
          end 
        end
      end
    end 
  end

  def protects_against_trauma?(kind)
    if self.kind == :ring_of_fire_resistance && kind == :burn
      return true
    end
    if self.kind == :ring_of_cold_resistance && kind == :frostbite
      return true
    end
    return false
  end
end