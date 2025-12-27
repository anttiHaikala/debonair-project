class Armor < Item
  # Blueprint data for all armor kinds
  ARMOR_DATA = {
    hat: {
      coverage: { head: 1 },
      meta: { ui_name: "hat", armor_type: :helmet, material: :fabric, weight: 0.2, rarity: 100, price: 2, can_eat: true }
    },
    big_helmet: {
      coverage: { head: 4 },
      meta: { ui_name: "big helmet", armor_type: :helmet_big, material: :metal, weight: 3.5, rarity: 100, price: 15, can_eat: true }
    },
    basic_helmet: {
      coverage: { head: 4 },
      meta: { ui_name: "boring helmet", armor_type: :helmet, material: :metal, weight: 1.8, rarity: 100, price: 25, can_eat: true }
    },
    corinthian_helmet: {
      coverage: { face: 2, head: 4 },
      meta: { ui_name: "corinthian helmet", armor_type: :helmet_visor, material: :metal, weight: 2.5, eyesight: -1, rarity: 10, price: 120, can_eat: true }
    },
    viking_helmet: {
      coverage: { face: 1, head: 4 },
      meta: { ui_name: "viking helmet", armor_type: :helmet_visor, material: :metal, weight: 2.0, eyesight: -1, rarity: 50, price: 45, can_eat: true }
    },
    modern_helmet: {
      coverage: { face: 1, head: 5 },
      meta: { ui_name: "kevlar helmet with goggles", armor_type: :helmet_visor, material: :kevlar, weight: 1.4, eyesight: 2, rarity: 5, price: 200, can_eat: true }
    },
    leather_hood: {
      coverage: { head: 1, neck: 1 },
      meta: { ui_name: "leather hood", armor_type: :hood, material: :leather, weight: 0.5, rarity: 100, price: 12, can_eat: true }
    },
    chain_mail_hood: {
      coverage: { head: 3, neck: 3 },
      meta: { ui_name: "chain hood", armor_type: :hood, material: :metal, weight: 1.2, rarity: 50, price: 40, can_eat: true }
    },
    gorget: {
      coverage: { neck: 3 },
      meta: { ui_name: "gorget", armor_type: :neck, material: :metal, weight: 1.2, rarity: 50, price: 40, can_eat: true }
    },
    stylish_scarf: {
      coverage: { neck: 0 },
      meta: { ui_name: "stylish scarf", armor_type: :neck, material: :fabric, weight: 0.3, rarity: 50, price: 200, can_eat: true }
    },
    leather_armor_shirt: {
      coverage: { upper_torso: 2, right_arm: 2, left_arm: 2 },
      meta: { ui_name: "leather shirt", armor_type: :shirt, material: :leather, weight: 4.5, rarity: 100, price: 45, can_eat: true }
    },
    chain_mail_shirt: {
      coverage: { upper_torso: 3, right_arm: 2, left_arm: 2 },
      meta: { ui_name: "chain shirt", armor_type: :shirt, material: :metal, weight: 10.0, rarity: 50, price: 110, can_eat: true }
    },
    lamellar_armor_shirt: {
      coverage: { upper_torso: 4, right_arm: 4, left_arm: 4 },
      meta: { ui_name: "lamellar shirt", armor_type: :shirt, material: :metal, weight: 12.0, rarity: 30, price: 220, can_eat: true }
    },
    breastplate: {
      coverage: { upper_torso: 5 },
      meta: { ui_name: "breastplate", armor_type: :vest, material: :metal, weight: 12.0, mobility: -2, rarity: 10, price: 450, can_eat: true }
    },
    leather_armor_coat: {
      coverage: { upper_torso: 2, lower_torso: 2, right_arm: 2, left_arm: 2 },
      meta: { ui_name: "leather armor coat", armor_type: :coat, material: :leather, weight: 6.5, rarity: 100, price: 65, can_eat: true }
    },
    chain_mail_coat: {
      coverage: { upper_torso: 3, lower_torso: 3, right_arm: 3, left_arm: 3 },
      meta: { ui_name: "chain coat", armor_type: :coat, material: :metal, weight: 14.0, rarity: 50, price: 140, can_eat: true }
    },
    leather_armor_pants: {
      coverage: { lower_torso: 2, right_leg: 2, left_leg: 2 },
      meta: { ui_name: "leather pants", armor_type: :pants, material: :leather, weight: 4.0, rarity: 100, price: 40, can_eat: true }
    },
    chain_mail_pants: {
      coverage: { lower_torso: 2, right_leg: 2, left_leg: 2 },
      meta: { ui_name: "chain pants", armor_type: :pants, material: :metal, weight: 9.0, rarity: 50, price: 90, can_eat: true }
    },
    lamellar_armor_pants: {
      coverage: { lower_torso: 4, right_leg: 4, left_leg: 4 },
      meta: { ui_name: "lamellar pants", armor_type: :pants, material: :metal, weight: 11.0, rarity: 30, price: 180, can_eat: true }
    },
    plate_mail_pants: {
      coverage: { lower_torso: 5, right_leg: 5, left_leg: 5 },
      meta: { ui_name: "plate pants", armor_type: :pants, material: :metal, weight: 11.0, mobility: -2, rarity: 10, price: 350, can_eat: true }
    },
    leather_boots: {
      coverage: { right_leg: 1, left_leg: 1 },
      meta: { ui_name: "leather boots", armor_type: :footwear, material: :leather, weight: 1.5, rarity: 100, price: 20, can_eat: true }
    },
    plate_shoes: {
      coverage: { right_leg: 5, left_leg: 5 },
      meta: { ui_name: "plate shoes", armor_type: :footwear, material: :metal, weight: 2.0, stealth: -1, rarity: 10, price: 200, can_eat: true }
    },
    greaves: {
      coverage: { right_leg: 2, left_leg: 2 },
      meta: { ui_name: "greaves", armor_type: :footwear, material: :metal, weight: 3.0, rarity: 50, price: 80, can_eat: true }
    },
    leather_gloves: {
      coverage: { right_arm: 1, left_arm: 1 },
      meta: { ui_name: "leather gloves", armor_type: :gloves, material: :leather, weight: 0.5, rarity: 100, price: 10, can_eat: true }
    },
    gauntlets: {
      coverage: { right_arm: 2, left_arm: 2 },
      meta: { ui_name: "gauntlets", armor_type: :gloves, material: :metal, weight: 1.2, rarity: 50, price: 120, can_eat: true }
    },
    ninja_suit: {
      coverage: { face: 0, head: 0, neck: 0, upper_torso: 0, lower_torso: 0, right_arm: 0, left_arm: 0, right_leg: 0, left_leg: 0 },
      meta: { ui_name: "ninja suit", armor_type: :stocking_suit, material: :fabric, weight: 1.5, stealth: 1, rarity: 10, price: 500, can_eat: true }
    },
    mutant_suit: {
      coverage: { head: 0, neck: 0, upper_torso: 0, lower_torso: 0, right_arm: 0, left_arm: 0, right_leg: 0, left_leg: 0 },
      meta: { ui_name: "silly stocking suit", armor_type: :stocking_suit, material: :fabric, weight: 1.5, mobility: 2, rarity: 5, price: 750, can_eat: true }
    },
    fur_shorts: {
      coverage: { lower_torso: 1, right_leg: 1, left_leg: 1 },
      meta: { ui_name: "fur shorts", armor_type: :shorts, material: :leather, weight: 1.0, rarity: 100, price: 10, can_eat: true }
    },
    leather_armor_skirt: {
      coverage: { lower_torso: 2, right_leg: 1, left_leg: 1 },
      meta: { ui_name: "leather skirt", armor_type: :skirt, material: :leather, weight: 2.0, rarity: 100, price: 35, can_eat: true }
    },
    lamellar_armor_skirt: {
      coverage: { lower_torso: 4, right_leg: 4, left_leg: 4 },
      meta: { ui_name: "lamellar skirt", armor_type: :skirt, material: :metal, weight: 6.0, rarity: 30, price: 160, can_eat: true }
    },
    cyborg_face: {
      coverage: { face: 1 },
      meta: { ui_name: "cyborg face", armor_type: :cyborg_part, material: :mixed, weight: 2.0, eyesight: 3.0, rarity: 10, price: 1500, can_eat: false }
    },
    cyborg_arm_left: {
      coverage: { left_arm: 3 },
      meta: { ui_name: "cyborg arm (L)", armor_type: :cyborg_part, material: :hi_tech, weight: 12.0, rarity: 10, price: 2500, can_eat: true }
    },
    cyborg_arm_right: {
      coverage: { right_arm: 3 },
      meta: { ui_name: "cyborg arm (R)", armor_type: :cyborg_part, material: :hi_tech, weight: 12.0, rarity: 10, price: 2500, can_eat: true }
    },
    cyborg_leg_left: {
      coverage: { left_leg: 4 },
      meta: { ui_name: "cyborg leg (L)", armor_type: :cyborg_part, material: :hi_tech, weight: 24.0, rarity: 10, price: 3000, can_eat: true }
    },
    cyborg_leg_right: {
      coverage: { right_leg: 4 },
      meta: { ui_name: "cyborg leg (R)", armor_type: :cyborg_part, material: :hi_tech, weight: 24.0, rarity: 10, price: 3000, can_eat: true }
    },
    cyborg_torso: {
      coverage: { upper_torso: 4, lower_torso: 4 },
      meta: { ui_name: "cyborg torso", armor_type: :cyborg_part, material: :hi_tech, weight: 40.0, rarity: 10, price: 5000, can_eat: true }
    }
  }

  # Logic: I am wearing the KEY (Row), can I wear the VALUE (Column)?
  COMPATIBILITY_MATRIX = {
    helmet:        { helmet: false, helmet_big: false, helmet_visor: false, hood: false, face: true,  neck: true,  vest: true,  shirt: true,  coat: true,  pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  cyborg_part: true },
    helmet_big:    { helmet: false, helmet_big: false, helmet_visor: false, hood: false, face: true,  neck: true,  vest: true,  shirt: true,  coat: true,  pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  cyborg_part: true },
    helmet_visor:  { helmet: false, helmet_big: false, helmet_visor: false, hood: false, face: false, neck: true,  vest: true,  shirt: true,  coat: true,  pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  cyborg_part: true },
    hood:          { helmet: false, helmet_big: true,  helmet_visor: false, hood: false, face: true,  neck: true,  vest: true,  shirt: true,  coat: true,  pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  cyborg_part: true },
    face:          { helmet: true,  helmet_big: true,  helmet_visor: false, hood: true,  face: false, neck: true,  vest: true,  shirt: true,  coat: true,  pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  cyborg_part: true },
    neck:          { helmet: true,  helmet_big: true,  helmet_visor: true,  hood: false, face: true,  neck: false, vest: true,  shirt: true,  coat: true,  pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  cyborg_part: true },
    vest:          { helmet: true,  helmet_big: true,  helmet_visor: true,  hood: true,  face: true,  neck: true,  vest: false, shirt: false, coat: false, pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  cyborg_part: true },
    shirt:         { helmet: true,  helmet_big: true,  helmet_visor: true,  hood: true,  face: true,  neck: true,  vest: false, shirt: false, coat: false, pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  cyborg_part: true },
    coat:          { helmet: true,  helmet_big: true,  helmet_visor: true,  hood: true,  face: true,  neck: true,  vest: false, shirt: false, coat: false, pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  cyborg_part: true },
    pants:         { helmet: true,  helmet_big: true,  helmet_visor: true,  hood: true,  face: true,  neck: true,  vest: true,  shirt: true,  coat: true,  pants: false, footwear: true,  gloves: true,  shorts: false, skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  cyborg_part: true },
    footwear:      { helmet: true,  helmet_big: true,  helmet_visor: true,  hood: true,  face: true,  neck: true,  vest: true,  shirt: true,  coat: true,  pants: true,  footwear: false, gloves: true,  shorts: true,  skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  cyborg_part: true },
    gloves:        { helmet: true,  helmet_big: true,  helmet_visor: true,  hood: true,  face: true,  neck: true,  vest: true,  shirt: true,  coat: true,  pants: true,  footwear: true,  gloves: false, shorts: true,  skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  cyborg_part: true },
    shorts:        { helmet: true,  helmet_big: true,  helmet_visor: true,  hood: true,  face: true,  neck: true,  vest: true,  shirt: true,  coat: true,  pants: false, footwear: true,  gloves: true,  shorts: false, skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  cyborg_part: true },
    skirt:         { helmet: true,  helmet_big: true,  helmet_visor: true,  hood: true,  face: true,  neck: true,  vest: true,  shirt: true,  coat: true,  pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: false, stocking_suit: true,  robe: true,  cloack: true,  cyborg_part: true },
    stocking_suit: { helmet: true,  helmet_big: true,  helmet_visor: true,  hood: true,  face: true,  neck: true,  vest: true,  shirt: true,  coat: true,  pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: true,  stocking_suit: false, robe: true,  cloack: true,  cyborg_part: true },
    robe:          { helmet: true,  helmet_big: true,  helmet_visor: true,  hood: true,  face: true,  neck: true,  vest: true,  shirt: true,  coat: true,  pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: true,  stocking_suit: false, robe: false, cloack: true,  cyborg_part: true },
    cloack:        { helmet: true,  helmet_big: true,  helmet_visor: true,  hood: true,  face: true,  neck: true,  vest: true,  shirt: true,  coat: true,  pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: true,  stocking_suit: false, robe: true,  cloack: false, cyborg_part: true },
    cyborg_part:   { helmet: true,  helmet_big: true,  helmet_visor: true,  hood: true,  face: true,  neck: true,  vest: true,  shirt: true,  coat: true,  pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  cyborg_part: true }
  }

  attr_accessor :coverage, :meta

  def initialize(kind, args=nil, &block)
    blueprint = ARMOR_DATA[kind] || { coverage: {}, meta: {} }
    @coverage = blueprint[:coverage].dup
    @meta     = blueprint[:meta].dup
    @weight   = @meta[:weight] || 4.0
    #@name     = @meta[:ui_name] || kind.to_s.gsub('_', ' ')

    super(kind, :armor, &block)
  end

  def self.common_attributes
    [:rusty, :moldy, :broken, :fine, :crude, :colourful, :shiny, :expensive, :made_in_Mordor, :comfortable]
  end

  def self.rare_attributes
    [:masterwork, :enchanted, :alien_made, :mythical, :made_by_Ilmarinen]
  end

  def apply_attribute_modifiers(args, attribute)
    return if @attributes.include?(attribute)
    case attribute
    when :rusty, :moldy, :broken
      @coverage.each { |part, val| @coverage[part] = [0, val - 1].max }
    when :fine
      @coverage.each { |part, val| @coverage[part] = val + 1 }
    when :crude
      @coverage.each { |part, val| @coverage[part] = [0, val - args.state.rng.nxt_int(0, 1)].max }
    when :colourful
      @meta[:stealth] = (@meta[:stealth] || 0) - 1
    when :shiny
      @coverage.each { |part, val| @coverage[part] = val + args.state.rng.nxt_int(0, 1) }
    when :comfortable
      @weight = (@weight * 0.8)
    when :expensive
      @meta[:price] = ((@meta[:price] || 10) * 1.5).floor
    when :made_in_Mordor
      @coverage.each { |part, val| @coverage[part] = [0, val - args.state.rng.nxt_int(-2, 1)].max }
    when :masterwork, :enchanted, :alien_made, :mythical, :made_by_Ilmarinen
      @coverage.each { |part, val| @coverage[part] = val + args.state.rng.nxt_int(1, 2) }
    end
  end

  def self.randomize(level_depth, args)
    kind = self.kinds[args.state.rng.nxt_int(0, self.kinds.length - 1)]
    armor = self.new(kind)
    armor.depth = level_depth
    
    common_roll = args.state.rng.d6
    secondary_common_roll = args.state.rng.d8
    rare_roll = args.state.rng.d20
    aSample = nil

    if rare_roll == 20
      rare_attrs = self.rare_attributes
      aSample = rare_attrs[args.state.rng.nxt_int(0, rare_attrs.length - 1)]
      armor.apply_attribute_modifiers(args, aSample)
      armor.add_attribute(aSample)
    else
      common_attrs = self.common_attributes
      aSample = common_attrs[args.state.rng.nxt_int(0, common_attrs.length - 1)]
      
      if aSample == :rusty
        if armor.meta[:material] == :leather || armor.meta[:material] == :fabric
          aSample = :moldy
        end
      end

      if common_roll <= 2
        armor.apply_attribute_modifiers(args, aSample)
        armor.add_attribute(aSample)
      end

      if secondary_common_roll == 1
        armor.apply_attribute_modifiers(args, aSample)
        armor.add_attribute(aSample)
      end
    end
    armor
  end

  def self.random(level_depth, args); self.randomize(level_depth, args); end
  def self.kinds; ARMOR_DATA.keys; end
  def armor_type; @meta[:armor_type]; end
  def body_parts_covered; @coverage.keys; end

  def protection_value(body_part, hit_kind, args)
    return nil unless @coverage.key?(body_part)
    @coverage[body_part]
  end

  def can_wear_with?(other_armor)
    type_a, type_b = self.armor_type, other_armor.armor_type
    matrix_row = COMPATIBILITY_MATRIX[type_a]
    return false unless matrix_row
    matrix_row[type_b] == true
  end

  def use(user, args)
    return unless user == args.state.hero
    if user.worn_items.include?(self)
      user.worn_items.delete(self)
      HUD.output_message(args, "You take off the #{self.title(args)}.")
      return
    end

    same_type_armor = user.worn_items.find { |item| item.is_a?(Armor) && item.armor_type == self.armor_type }
    if same_type_armor
      user.worn_items.delete(same_type_armor)
      user.worn_items << self
      HUD.output_message(args, "You swap your #{same_type_armor.title(args)} for the #{self.title(args)}.")
    else
      conflict = user.worn_items.find { |worn| worn.is_a?(Armor) && !worn.can_wear_with?(self) }
      if conflict.nil?
        user.worn_items << self
        HUD.output_message(args, "You put on the #{self.title(args)}.")
      else
        HUD.output_message(args, "You cannot put the #{self.title(args)} on over your #{conflict.title(args)}!")
      end
    end
  end
end