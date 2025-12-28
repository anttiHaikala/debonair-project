class Potion < Item

  def initialize(kind,args=nil)    
    super(kind, :potion)
  end

  def self.kinds
    [
    :potion_of_healing,
    :potion_of_strength,
    :potion_of_speed,
    :potion_of_invisibility,
    # :potion_of_fire_resistance,
    # :potion_of_cold_resistance,
    :potion_of_poison,
    # :potion_of_water_breathing,
    # :potion_of_levitation,
    :potion_of_telepathy,
    :potion_of_extra_healing,
    :potion_of_teleportation,
    :potion_of_holy_water,
    :potion_of_confusion
    ]
  end

  def self.setup_masks(args)
    self.mask_pool.shuffle
  end

  def self.masks(args)
    args.state.run.potion_masks
  end

  def self.mask_pool
    [
      :pink,
      :blue,
      :yellow,
      :brown,
      :green,
      :red,
      :white,
      :black,
      :purple,
      :turquoise,
      :orange,
      :gray
    ]
  end

  def title(args)
    mask_index = Potion.kinds.index(self.kind) % Potion.masks(args).length
    mask = Potion.masks(args)[mask_index]
    if args.state.hero.known_potions.include?(self.kind)
      "#{self.attributes.join(' ')} #{mask} potion (#{self.kind.to_s.gsub('potion_of_','')})".trim
    else
      "#{mask} potion".trim
    end
  end

  def self.randomize(level_depth, args)
    kind = args.state.rng.choice(self.kinds)
    return Potion.new(kind)
  end

  def identify(args)
    unless args.state.hero.known_potions.include?(self.kind)
      args.state.hero.known_potions << self.kind
    end
  end

  def use(entity, args)
    identify = true
    base_duration = 70
    case self.kind
    when :potion_of_teleportation
      HUD.output_message(args, "You feel disoriented...")
      entity.teleport(args)
      self.identify(args)
    when :potion_of_healing, :potion_of_extra_healing
      effect = 0
      Trauma.active_traumas(entity).each do |trauma|
        roll = args.state.rng.d12 
        if roll >= trauma.numeric_severity
          trauma.heal_one_step
          effect += 1
        end
        if self.kind == :potion_of_extra_healing
          # extra healing potion heals faster
          roll = args.state.rng.d20
          if roll >= trauma.numeric_severity
            trauma.heal_one_step
            effect += 1
          end
        end
      end
      if effect == 0
        HUD.output_message(args, "You don't feel that different after drinking the #{self.title(args)}.")
        identify = false
      else
        HUD.output_message(args, "You feel better after drinking the #{self.title(args)}.")
        SoundFX.play(:heal, args)
      end
      SoundFX.play(:potion, args)
    when :potion_of_poison
      HUD.output_message(args, "Ouch! This potion did not improve my well-being.")
      Status.new(entity, :poison, 20 + args.state.rng.d10, args)
    when :potion_of_strength
      HUD.output_message(args, "You feel stronger!")
      Status.new(entity, :strenghtened, base_duration + args.state.rng.d20 * 2, args)
    when :potion_of_speed
      HUD.output_message(args, "You feel world around you slowing down!")
      Status.new(entity, :speedy, base_duration + args.state.rng.d20 * 2, args)
    when :potion_of_invisibility
      HUD.output_message(args, "You become invisible!")
      Status.new(entity, :invisible, base_duration + args.state.rng.d20 * 2, args)
    when :potion_of_telepathy
      HUD.output_message(args, "You feel more connected to other beings!")
      Status.new(entity, :telepathic, base_duration + args.state.rng.d20 * 2, args)
      SoundFX.play(:telepathy, args)
    when :potion_of_holy_water
      HUD.output_message(args, "You feel holy!")
      Status.new(entity, :holy_water, base_duration + args.state.rng.d20 * 2, args)
      SoundFX.play(:holy_water, args)
    when :potion_of_confusion
      HUD.output_message(args, "You feel confused!")
      Status.new(entity, :confused, base_duration + args.state.rng.d20 * 2, args)
      SoundFX.play(:confusion, args)
    else
      HUD.output_message(args, "You feel strange...")
      identify = false
    end
    self.identify(args) if identify
    entity.carried_items.delete(self)
    args.state.kronos.spend_time(entity, entity.walking_speed, args)
  end
end