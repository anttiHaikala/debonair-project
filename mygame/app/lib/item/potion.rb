class Potion < Item
  # --- POTION BLUEPRINT DATA ---
  DATA = {
    potion_of_healing: {
      meta: { ui_name: "healing potion", weight: 0.5, price: 50, occurance: 1.0, description: "A bottle of magical liquid." }
    },
    potion_of_strength: {
      meta: { ui_name: "strength potion", weight: 0.5, price: 80, occurance: 0.4, description: "A bottle of magical liquid." }
    },
    potion_of_speed: {
      meta: { ui_name: "speed potion", weight: 0.5, price: 80, occurance: 0.4, description: "A bottle of magical liquid." }
    },
    potion_of_invisibility: {
      meta: { ui_name: "invisibility potion", weight: 0.5, price: 120, occurance: 0.3, description: "A bottle of magical liquid." }
    },
    potion_of_poison: {
      meta: { ui_name: "poison potion", weight: 0.5, price: 20, occurance: 0.5, description: "A bottle of magical liquid." }
    },
    potion_of_telepathy: {
      meta: { ui_name: "telepathy potion", weight: 0.5, price: 100, occurance: 0.3, description: "A bottle of magical liquid." }
    },
    potion_of_extra_healing: {
      meta: { ui_name: "extra healing potion", weight: 0.5, price: 150, occurance: 0.2, description: "A bottle of magical liquid." }
    },
    potion_of_teleportation: {
      meta: { ui_name: "teleportation potion", weight: 0.5, price: 60, occurance: 0.4, description: "A bottle of magical liquid." }
    },
    potion_of_holy_water: {
      meta: { ui_name: "holy water", weight: 0.5, price: 100, occurance: 0.2, description: "A bottle of magical liquid." }
    },
    potion_of_confusion: {
      meta: { ui_name: "confusion potion", weight: 0.5, price: 30, occurance: 0.4, description: "A bottle of magical liquid." }
    }
  }

  #to do
  # :potion_of_fire_resistance,
  # :potion_of_cold_resistance,
  # :potion_of_water_breathing,
  # :potion_of_levitation,

  attr_accessor :meta, :weight, :price, :occurrence, :description

  def initialize(kind, args = nil)
    blueprint = DATA[kind] || { meta: {} }
    @meta = (blueprint[:meta] || {}).dup
    
    # Extract data from meta hash
    @weight      = @meta[:weight]      || 0.5
    @price       = @meta[:price]       || 50
    @occurrence  = @meta[:occurance]   || 0.5
    @description = @meta[:description] || "A mysterious potion of unknown origin."
    
    super(kind, :potion)
  end

  def self.kinds
    DATA.keys
  end

  def self.setup_masks(args)
    self.mask_pool.shuffle
  end

  def self.masks(args)
    args.state.run.potion_masks
  end

  def self.mask_pool
    [:pink, :blue, :yellow, :brown, :green, :red, :white, :black, :purple, :turquoise, :orange, :gray]
  end

  def title(args)
    mask_index = self.class.kinds.index(self.kind) % self.class.masks(args).length
    mask = self.class.masks(args)[mask_index]
    if args.state.hero.known_potions.include?(self.kind)
      "#{self.attributes.join(' ')} #{mask} potion (#{self.kind.to_s.gsub('potion_of_','')})".strip
    else
      "#{mask} potion".strip
    end
  end

  def self.randomize(level_depth, args)
    kind = args.state.rng.choice(self.kinds)
    return self.new(kind, args)
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
    when :potion_of_healing, :potion_of_extra_healing
      effect = 0
      Trauma.active_traumas(entity).each do |trauma|
        roll = args.state.rng.d12 
        if roll >= trauma.numeric_severity
          trauma.heal_one_step
          effect += 1
        end
        if self.kind == :potion_of_extra_healing
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