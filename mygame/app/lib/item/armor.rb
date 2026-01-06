class Armor < Item
  # Blueprint data for all armor kinds
  DATA = {
    hat: {
      coverage: { head: 1 },
      meta: { ui_name: "hat", armor_type: :helmet, material: :organic, weight: 0.2, occurance: 1.0, price: 2, can_eat: true, vision: 0 }
    },
    big_helmet: {
      coverage: { head: 4 },
      meta: { ui_name: "big helmet", armor_type: :helmet_big, material: :metal, weight: 3.5, occurance: 1.0, price: 15, can_eat: true, vision: 0 }
    },
    basic_helmet: {
      coverage: { head: 4 },
      meta: { ui_name: "boring helmet", armor_type: :helmet, material: :metal, weight: 1.8, occurance: 1.0, price: 25, can_eat: true, vision: 0 }
    },
    corinthian_helmet: {
      coverage: { face: 2, head: 4 },
      meta: { ui_name: "corinthian helmet", armor_type: :helmet_visor, material: :metal, weight: 2.5, eyesight: -1, occurance: 0.1, price: 120, can_eat: true, vision: -1 }
    },
    viking_helmet: {
      coverage: { face: 1, head: 4 },
      meta: { ui_name: "viking helmet", armor_type: :helmet_visor, material: :metal, weight: 2.0, eyesight: -1, occurance: 0.2, price: 45, can_eat: true, vision: -1 }
    },
    kinght_helmet: {
      coverage: { face: 4, head: 4 },
      meta: { ui_name: "knight helmet", armor_type: :helmet_visor, material: :metal, weight: 2.0, eyesight: -1, occurance: 0.2, price: 65, can_eat: false, vision: -2 }
    },
    modern_helmet: {
      coverage: { face: 1, head: 5 },
      meta: { ui_name: "kevlar helmet with goggles", armor_type: :helmet_visor, material: :syntethic, weight: 1.4, eyesight: 2, occurance: 0.05, price: 200, can_eat: true, vision: 2 }
    },
    leather_hood: {
      coverage: { head: 1, neck: 1 },
      meta: { ui_name: "leather hood", armor_type: :hood, material: :organic, weight: 0.5, occurance: 1.0, price: 12, can_eat: true, vision: 0 }
    },
    chain_mail_hood: {
      coverage: { head: 3, neck: 3 },
      meta: { ui_name: "chain hood", armor_type: :hood, material: :metal, weight: 1.2, occurance: 0.5, price: 40, can_eat: true, vision: 0 }
    },
    gorget: {
      coverage: { neck: 3 },
      meta: { ui_name: "gorget", armor_type: :neck, material: :metal, weight: 1.2, occurance: 0.5, price: 40, can_eat: true, vision: 0 }
    },
    stylish_scarf: {
      coverage: { neck: 0 },
      meta: { ui_name: "stylish scarf", armor_type: :neck, material: :organic, weight: 0.3, occurance: 0.5, price: 200, can_eat: true, vision: 0 }
    },
    leather_armor_shirt: {
      coverage: { upper_torso: 2, right_arm: 2, left_arm: 2 },
      meta: { ui_name: "leather shirt", armor_type: :shirt, material: :organic, weight: 4.5, occurance: 1.0, price: 45, can_eat: true, vision: 0 }
    },
    chain_mail_shirt: {
      coverage: { upper_torso: 3, right_arm: 2, left_arm: 2 },
      meta: { ui_name: "chain shirt", armor_type: :shirt, material: :metal, weight: 10.0, occurance: 0.5, price: 110, can_eat: true, vision: 0 }
    },
    lamellar_armor_shirt: {
      coverage: { upper_torso: 4, right_arm: 4, left_arm: 4 },
      meta: { ui_name: "lamellar shirt", armor_type: :shirt, material: :metal, weight: 12.0, occurance: 0.3, price: 220, can_eat: true, vision: 0 }
    },
    breastplate: {
      coverage: { upper_torso: 5 },
      meta: { ui_name: "breastplate", armor_type: :vest, material: :metal, weight: 12.0, mobility: -2, occurance: 0.1, price: 450, can_eat: true, vision: 0 }
    },
    leather_armor_coat: {
      coverage: { upper_torso: 2, lower_torso: 2, right_arm: 2, left_arm: 2 },
      meta: { ui_name: "leather armor coat", armor_type: :coat, material: :organic, weight: 6.5, occurance: 1.0, price: 65, can_eat: true, vision: 0 }
    },
    chain_mail_coat: {
      coverage: { upper_torso: 3, lower_torso: 3, right_arm: 3, left_arm: 3 },
      meta: { ui_name: "chain coat", armor_type: :coat, material: :metal, weight: 14.0, occurance: 0.5, price: 140, can_eat: true, vision: 0 }
    },
    leather_armor_pants: {
      coverage: { lower_torso: 2, right_leg: 2, left_leg: 2 },
      meta: { ui_name: "leather pants", armor_type: :pants, material: :organic, weight: 4.0, occurance: 1.0, price: 40, can_eat: true, vision: 0 }
    },
    chain_mail_pants: {
      coverage: { lower_torso: 2, right_leg: 2, left_leg: 2 },
      meta: { ui_name: "chain pants", armor_type: :pants, material: :metal, weight: 9.0, occurance: 0.5, price: 90, can_eat: true, vision: 0 }
    },
    lamellar_armor_pants: {
      coverage: { lower_torso: 4, right_leg: 4, left_leg: 4 },
      meta: { ui_name: "lamellar pants", armor_type: :pants, material: :metal, weight: 11.0, occurance: 0.3, price: 180, can_eat: true, vision: 0 }
    },
    plate_mail_pants: {
      coverage: { lower_torso: 5, right_leg: 5, left_leg: 5 },
      meta: { ui_name: "plate pants", armor_type: :pants, material: :metal, weight: 11.0, mobility: -2, occurance: 0.1, price: 350, can_eat: true, vision: 0 }
    },
    leather_boots: {
      coverage: { right_leg: 1, left_leg: 1 },
      meta: { ui_name: "leather boots", armor_type: :footwear, material: :organic, weight: 1.5, occurance: 1.0, price: 20, can_eat: true, vision: 0 }
    },
    plate_shoes: {
      coverage: { right_leg: 5, left_leg: 5 },
      meta: { ui_name: "plate shoes", armor_type: :footwear, material: :metal, weight: 2.0, stealth: -1, occurance: 0.1, price: 200, can_eat: true, vision: 0 }
    },
    greaves: {
      coverage: { right_leg: 2, left_leg: 2 },
      meta: { ui_name: "greaves", armor_type: :footwear, material: :metal, weight: 3.0, occurance: 0.5, price: 80, can_eat: true, vision: 0 }
    },
    leather_gloves: {
      coverage: { right_arm: 1, left_arm: 1 },
      meta: { ui_name: "leather gloves", armor_type: :gloves, material: :organic, weight: 0.5, occurance: 1.0, price: 10, can_eat: true, vision: 0 }
    },
    gauntlets: {
      coverage: { right_arm: 2, left_arm: 2 },
      meta: { ui_name: "gauntlets", armor_type: :gloves, material: :metal, weight: 1.2, occurance: 0.5, price: 120, can_eat: true, vision: 0 }
    },
    ninja_suit: {
      coverage: { face: 0, head: 0, neck: 0, upper_torso: 0, lower_torso: 0, right_arm: 0, left_arm: 0, right_leg: 0, left_leg: 0 },
      meta: { ui_name: "ninja suit", armor_type: :stocking_suit, material: :organic, weight: 1.5, stealth: 1, occurance: 0.1, price: 500, can_eat: true, vision: 0 }
    },
    mutant_suit: {
      coverage: { head: 0, neck: 0, upper_torso: 0, lower_torso: 0, right_arm: 0, left_arm: 0, right_leg: 0, left_leg: 0 },
      meta: { ui_name: "silly stocking suit", armor_type: :stocking_suit, material: :organic, weight: 1.5, mobility: 2, occurance: 0.05, price: 750, can_eat: true, vision: 0 }
    },
    fur_shorts: {
      coverage: { lower_torso: 1, right_leg: 1, left_leg: 1 },
      meta: { ui_name: "fur shorts", armor_type: :shorts, material: :organic, weight: 1.0, occurance: 1.0, price: 10, can_eat: true, vision: 0 }
    },
    leather_armor_skirt: {
      coverage: { lower_torso: 2, right_leg: 1, left_leg: 1 },
      meta: { ui_name: "leather skirt", armor_type: :skirt, material: :organic, weight: 2.0, occurance: 1.0, price: 35, can_eat: true, vision: 0 }
    },
    lamellar_armor_skirt: {
      coverage: { lower_torso: 4, right_leg: 4, left_leg: 4 },
      meta: { ui_name: "lamellar skirt", armor_type: :skirt, material: :metal, weight: 6.0, occurance: 0.3, price: 160, can_eat: true, vision: 0 }
    },
    cyborg_face: {
      coverage: { face: 1 },
      meta: { ui_name: "cyborg face", armor_type: :cyborg_part, material: :syntethic, weight: 2.0, eyesight: 3.0, occurance: 0.01, price: 1500, can_eat: false, vision: 0 }
    },
    cyborg_arm_left: {
      coverage: { left_arm: 3 },
      meta: { ui_name: "cyborg arm (L)", armor_type: :cyborg_part, material: :syntethic, weight: 10.0, occurance: 0.01, price: 2500, can_eat: true, vision: 0 }
    },
    cyborg_arm_right: {
      coverage: { right_arm: 3 },
      meta: { ui_name: "cyborg arm (R)", armor_type: :cyborg_part, material: :syntethic, weight: 10.0, occurance: 0.01, price: 2500, can_eat: true, vision: 0 }
    },
    cyborg_leg_left: {
      coverage: { left_leg: 4 },
      meta: { ui_name: "cyborg leg (L)", armor_type: :cyborg_part, material: :syntethic, weight: 19.0, occurance: 0.01, price: 3000, can_eat: true, vision: 0 }
    },
    cyborg_leg_right: {
      coverage: { right_leg: 4 },
      meta: { ui_name: "cyborg leg (R)", armor_type: :cyborg_part, material: :syntethic, weight: 19.0, occurance: 0.01, price: 3000, can_eat: true, vision: 0 }
    },
    cyborg_torso: {
      coverage: { upper_torso: 4, lower_torso: 4 },
      meta: { ui_name: "cyborg torso", armor_type: :cyborg_part, material: :syntethic, weight: 30.0, occurance: 0.01, price: 5000, can_eat: true, vision: 0 }
    },
    test_unique_item: {
      coverage: { upper_torso: 100, lower_torso: 100 },
      meta: { ui_name: "Armor of God", armor_type: :cyborg_part, material: :syntethic, weight: 0.0, occurance: 0.0, price: 5000, can_eat: true, vision: 0 }
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
    blueprint = DATA[kind] || { coverage: {}, meta: {} }
    @coverage = blueprint[:coverage].dup
    @meta     = blueprint[:meta].dup
    @weight   = @meta[:weight] || 4.0
    #@name     = @meta[:ui_name] || kind.to_s.gsub('_', ' ')

    super(kind, :armor, &block)
  end

  def self.data; DATA; end

  def self.common_attributes
    [:rusty, :moldy, :broken, :fine, :crude, :colourful, :shiny, :expensive, :made_in_Mordor, :comfortable, :enchanted, :cursed]
  end

  def self.rare_attributes
    [:masterwork, :alien_made, :mythical, :made_by_Ilmarinen, :holy]
  end

  # apply the effects of an attribute to this armor needs to be in subclass
  def apply_attribute_modifiers(attribute, args)
    return if @attributes.include?(attribute)
    case attribute
    when :rusty, :moldy, :broken
      @coverage.each { |part, val| @coverage[part] = [0, val - 1].max }
    when :cursed
      @coverage.each { |part, val| @coverage[part] -= 3}
    when :enchanted
      @coverage.each { |part, val| @coverage[part] += 3}
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
    when :masterwork, :enchanted, :alien_made, :mythical, :made_by_Ilmarinen, :holy
      @coverage.each { |part, val| @coverage[part] = val + args.state.rng.nxt_int(1, 2) }
    end
  end



  def self.random(level_depth, args); self.randomize(level_depth, args); end
  def self.kinds; DATA.keys; end
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

  def self.randomize(level_depth, args)
    Item.randomize(level_depth, self, args)
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