class Armor < Item
  # Blueprint data for all armor kinds
DATA = {
  hat: {
    coverage: { head: 1 },
    meta: { ui_name: "hat", description: "A simple woolen hat.", armor_type: :helmet, material: :organic, weight: 0.2, occurance: 1.0, price: 2, can_eat: true, vision: 0 }
  },
  big_helmet: {
    coverage: { head: 4 },
    meta: { ui_name: "big helmet", description: "A massive, heavy metal bucket that prioritizes safety over comfort.", armor_type: :helmet_big, material: :metal, weight: 3.5, occurance: 1.0, price: 15, can_eat: true, vision: 0 }
  },
  basic_helmet: {
    coverage: { head: 4 },
    meta: { ui_name: "boring helmet", description: "A standard, no-frills metal helmet.", armor_type: :helmet, material: :metal, weight: 1.8, occurance: 1.0, price: 25, can_eat: true, vision: 0 }
  },
  corinthian_helmet: {
    coverage: { face: 2, head: 4 },
    meta: { ui_name: "corinthian helmet", description: "An ancient bronze helmet that protects the face at the cost of peripheral vision.", armor_type: :helmet_visor, material: :metal, weight: 2.5, eyesight: -1, occurance: 0.1, price: 120, can_eat: true, vision: -1 }
  },
  viking_helmet: {
    coverage: { face: 1, head: 4 },
    meta: { ui_name: "viking helmet", description: "A rugged iron helmet with a distinctive nasal guard and eye-frames.", armor_type: :helmet_visor, material: :metal, weight: 2.0, eyesight: -1, occurance: 0.2, price: 45, can_eat: true, vision: -1 }
  },
  kinght_helmet: {
    coverage: { face: 4, head: 4 },
    meta: { ui_name: "knight helmet", description: "A fully enclosed plate helmet. Incredible protection, but you can barely see or breathe.", armor_type: :helmet_visor, material: :metal, weight: 2.0, eyesight: -1, occurance: 0.2, price: 65, can_eat: false, vision: -2 }
  },
  modern_helmet: {
    coverage: { face: 1, head: 5 },
    meta: { ui_name: "kevlar helmet with goggles", description: "High-tech synthetic protection featuring integrated tactical optics.", armor_type: :helmet_visor, material: :syntethic, weight: 1.4, eyesight: 2, occurance: 0.05, price: 200, can_eat: true, vision: 2 }
  },
  leather_hood: {
    coverage: { head: 1, neck: 1 },
    meta: { ui_name: "leather hood", description: "A simple cowhide hood that covers the head and throat.", armor_type: :hood, material: :organic, weight: 0.5, occurance: 1.0, price: 12, can_eat: true, vision: 0 }
  },
  chain_mail_hood: {
    coverage: { head: 3, neck: 3 },
    meta: { ui_name: "chain hood", description: "Interlocking metal rings woven into a flexible, protective hood.", armor_type: :hood, material: :metal, weight: 1.2, occurance: 0.5, price: 40, can_eat: true, vision: 0 }
  },
  gorget: {
    coverage: { neck: 3 },
    meta: { ui_name: "gorget", description: "A metal collar designed specifically to protect the vital areas of the neck.", armor_type: :neck, material: :metal, weight: 1.2, occurance: 0.5, price: 40, can_eat: true, vision: 0 }
  },
  stylish_scarf: {
    coverage: { neck: 0 },
    meta: { ui_name: "stylish scarf", description: "Purely aesthetic, but it makes you look like a very important person.", armor_type: :neck, material: :organic, weight: 0.3, occurance: 0.5, price: 200, can_eat: true, vision: 0 }
  },
  leather_armor_shirt: {
    coverage: { upper_torso: 2, right_arm: 2, left_arm: 2 },
    meta: { ui_name: "leather shirt", description: "Reinforced leather panels sewn onto a linen shirt.", armor_type: :shirt, material: :organic, weight: 4.5, occurance: 1.0, price: 45, can_eat: true, vision: 0 }
  },
  chain_mail_shirt: {
    coverage: { upper_torso: 3, right_arm: 2, left_arm: 2 },
    meta: { ui_name: "chain shirt", description: "A heavy shirt of mail.", armor_type: :shirt, material: :metal, weight: 10.0, occurance: 0.5, price: 110, can_eat: true, vision: 0 }
  },
  lamellar_armor_shirt: {
    coverage: { upper_torso: 4, right_arm: 4, left_arm: 4 },
    meta: { ui_name: "lamellar shirt", description: "A shirt of small metal plates laced together. Highly protective and flexible.", armor_type: :shirt, material: :metal, weight: 12.0, occurance: 0.3, price: 220, can_eat: true, vision: 0 }
  },
  breastplate: {
    coverage: { upper_torso: 5 },
    meta: { ui_name: "breastplate", description: "A solid piece of forged steel protecting torso.", armor_type: :vest, material: :metal, weight: 12.0, mobility: -2, occurance: 0.1, price: 450, can_eat: true, vision: 0 }
  },
  leather_armor_coat: {
    coverage: { upper_torso: 2, lower_torso: 2, right_arm: 2, left_arm: 2 },
    meta: { ui_name: "leather armor coat", description: "A long coat of thick leather that covers most of the upper body.", armor_type: :coat, material: :organic, weight: 6.5, occurance: 1.0, price: 65, can_eat: true, vision: 0 }
  },
  chain_mail_coat: {
    coverage: { upper_torso: 3, lower_torso: 3, right_arm: 3, left_arm: 3 },
    meta: { ui_name: "chain coat", description: "Full chainmail coverage from the shoulders down to the thighs.", armor_type: :coat, material: :metal, weight: 14.0, occurance: 0.5, price: 140, can_eat: true, vision: 0 }
  },
  leather_armor_pants: {
    coverage: { lower_torso: 2, right_leg: 2, left_leg: 2 },
    meta: { ui_name: "leather pants", description: "Hardened leather leggings that protect against low strikes.", armor_type: :pants, material: :organic, weight: 4.0, occurance: 1.0, price: 40, can_eat: true, vision: 0 }
  },
  chain_mail_pants: {
    coverage: { lower_torso: 2, right_leg: 2, left_leg: 2 },
    meta: { ui_name: "chain pants", description: "Mail leggings. Heavy and noisy, but they'll keep your legs attached.", armor_type: :pants, material: :metal, weight: 9.0, occurance: 0.5, price: 90, can_eat: true, vision: 0 }
  },
  lamellar_armor_pants: {
    coverage: { lower_torso: 4, right_leg: 4, left_leg: 4 },
    meta: { ui_name: "lamellar pants", description: "Individual plates laced over the legs for excellent defense.", armor_type: :pants, material: :metal, weight: 11.0, occurance: 0.3, price: 180, can_eat: true, vision: 0 }
  },
  plate_mail_pants: {
    coverage: { lower_torso: 5, right_leg: 5, left_leg: 5 },
    meta: { ui_name: "plate pants", description: "Full steel plate for the lower body. Significantly restricts movement.", armor_type: :pants, material: :metal, weight: 11.0, mobility: -2, occurance: 0.1, price: 350, can_eat: true, vision: 0 }
  },
  leather_boots: {
    coverage: { right_leg: 1, left_leg: 1 },
    meta: { ui_name: "leather boots", description: "Sturdy travel boots made from boiled leather.", armor_type: :footwear, material: :organic, weight: 1.5, occurance: 1.0, price: 20, can_eat: true, vision: 0 }
  },
  plate_shoes: {
    coverage: { right_leg: 5, left_leg: 5 },
    meta: { ui_name: "plate shoes", description: "Articulated steel footwear. Loud, clunky, and very protective.", armor_type: :footwear, material: :metal, weight: 2.0, stealth: -1, occurance: 0.1, price: 200, can_eat: true, vision: 0 }
  },
  greaves: {
    coverage: { right_leg: 2, left_leg: 2 },
    meta: { ui_name: "greaves", description: "Metal shin guards that protect against low-hanging hazards.", armor_type: :footwear, material: :metal, weight: 3.0, occurance: 0.5, price: 80, can_eat: true, vision: 0 }
  },
  leather_gloves: {
    coverage: { right_arm: 1, left_arm: 1 },
    meta: { ui_name: "leather gloves", description: "Hardened leather gloves to protect your hands from blisters and minor cuts.", armor_type: :gloves, material: :organic, weight: 0.5, occurance: 1.0, price: 10, can_eat: true, vision: 0 }
  },
  gauntlets: {
    coverage: { right_arm: 2, left_arm: 2 },
    meta: { ui_name: "gauntlets", description: "Steel-plated gloves designed for heavy combat.", armor_type: :gloves, material: :metal, weight: 1.2, occurance: 0.5, price: 120, can_eat: true, vision: 0 }
  },
  ninja_suit: {
    coverage: { face: 0, head: 0, neck: 0, upper_torso: 0, lower_torso: 0, right_arm: 0, left_arm: 0, right_leg: 0, left_leg: 0 },
    meta: { ui_name: "ninja suit", description: "A lightweight, dark suit that helps you blend into the shadows.", armor_type: :stocking_suit, material: :organic, weight: 1.5, stealth: 1, occurance: 0.1, price: 500, can_eat: true, vision: 0 }
  },
  mutant_suit: {
    coverage: { head: 0, neck: 0, upper_torso: 0, lower_torso: 0, right_arm: 0, left_arm: 0, right_leg: 0, left_leg: 0 },
    meta: { ui_name: "silly stocking suit", description: "A strange, hyper-elastic suit that makes you think you run faster.", armor_type: :stocking_suit, material: :organic, weight: 1.5, mobility: 2, occurance: 0.05, price: 750, can_eat: true, vision: 0 }
  },
  fur_shorts: {
    coverage: { lower_torso: 1, right_leg: 1, left_leg: 1 },
    meta: { ui_name: "fur shorts", description: "Primitive and itchy shorts made of bear skin. More comfortable with underwear.", armor_type: :shorts, material: :organic, weight: 1.0, occurance: 1.0, price: 10, can_eat: true, vision: 0 }
  },
  leather_armor_skirt: {
    coverage: { lower_torso: 2, right_leg: 1, left_leg: 1 },
    meta: { ui_name: "leather skirt", description: "Reinforced leather strips hanging from a belt.", armor_type: :skirt, material: :organic, weight: 2.0, occurance: 1.0, price: 35, can_eat: true, vision: 0 }
  },
  lamellar_armor_skirt: {
    coverage: { lower_torso: 4, right_leg: 4, left_leg: 4 },
    meta: { ui_name: "lamellar skirt", description: "A defensive skirt made of overlapping metal scales.", armor_type: :skirt, material: :metal, weight: 6.0, occurance: 0.3, price: 160, can_eat: true, vision: 0 }
  },
  magic_lizard_face: {
    coverage: { face: 1 },
    meta: { ui_name: "magic_lizard face", description: "A face skin of the lizard wizard from uknown legend. Wears on like a second skin", armor_type: :magic_lizard_part, material: :organic, weight: 2.0, eyesight: 3.0, occurance: 0.01, price: 1500, can_eat: false, vision: 0 }
  },
  magic_lizard_arm_left: {
    coverage: { left_arm: 3 },
    meta: { ui_name: "magic_lizard arm (L)", description: "Arm skin of the lizard wizard from uknown legend. Wears on like a second skin", armor_type: :magic_lizard_part, material: :organic, weight: 10.0, occurance: 0.001, price: 2500, can_eat: true, vision: 0 }
  },
  magic_lizard_arm_right: {
    coverage: { right_arm: 3 },
    meta: { ui_name: "magic_lizard arm (R)", description: "Arm skin of the lizard wizard from uknown legend. Wears on like a second skin", armor_type: :magic_lizard_part, material: :organic, weight: 10.0, occurance: 0.001, price: 2500, can_eat: true, vision: 0 }
  },
  magic_lizard_leg_left: {
    coverage: { left_leg: 4 },
    meta: { ui_name: "magic_lizard leg (L)", description: "Leg skin of the lizard wizard from uknown legend. Wears on like a second skin", armor_type: :magic_lizard_part, material: :organic, weight: 19.0, occurance: 0.001, price: 3000, can_eat: true, vision: 0 }
  },
  magic_lizard_leg_right: {
    coverage: { right_leg: 4 },
    meta: { ui_name: "magic_lizard leg (R)", description: "Leg skin of the lizard wizard from uknown legend. Wears on like a second skin", armor_type: :magic_lizard_part, material: :organic, weight: 19.0, occurance: 0.001, price: 3000, can_eat: true, vision: 0 }
  },
  magic_lizard_torso: {
    coverage: { upper_torso: 4, lower_torso: 4 },
    meta: { ui_name: "magic_lizard torso", description: "Body skin of the lizard wizard from uknown legend. Wears on like a second skin", armor_type: :magic_lizard_part, material: :organic, weight: 30.0, occurance: 0.001, price: 5000, can_eat: true, vision: 0 }
  },
  test_unique_item: {
    coverage: { upper_torso: 100, lower_torso: 100 },
    meta: { ui_name: "Armor of God", description: "An otherworldly relic that provides absolute protection to the faithful.", armor_type: :magic_lizard_part, material: :syntethic, weight: 0.0, occurance: 0.0, price: 5000, can_eat: true, vision: 0 }
  }
}
  # Logic: I am wearing the KEY (Row), can I wear the VALUE (Column)?
  COMPATIBILITY_MATRIX = {
    helmet:        { helmet: false, helmet_big: false, helmet_visor: false, hood: false, face: true,  neck: true,  vest: true,  shirt: true,  coat: true,  pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  magic_lizard_part: true },
    helmet_big:    { helmet: false, helmet_big: false, helmet_visor: false, hood: false, face: true,  neck: true,  vest: true,  shirt: true,  coat: true,  pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  magic_lizard_part: true },
    helmet_visor:  { helmet: false, helmet_big: false, helmet_visor: false, hood: false, face: false, neck: true,  vest: true,  shirt: true,  coat: true,  pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  magic_lizard_part: true },
    hood:          { helmet: false, helmet_big: true,  helmet_visor: false, hood: false, face: true,  neck: true,  vest: true,  shirt: true,  coat: true,  pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  magic_lizard_part: true },
    face:          { helmet: true,  helmet_big: true,  helmet_visor: false, hood: true,  face: false, neck: true,  vest: true,  shirt: true,  coat: true,  pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  magic_lizard_part: true },
    neck:          { helmet: true,  helmet_big: true,  helmet_visor: true,  hood: false, face: true,  neck: false, vest: true,  shirt: true,  coat: true,  pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  magic_lizard_part: true },
    vest:          { helmet: true,  helmet_big: true,  helmet_visor: true,  hood: true,  face: true,  neck: true,  vest: false, shirt: false, coat: false, pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  magic_lizard_part: true },
    shirt:         { helmet: true,  helmet_big: true,  helmet_visor: true,  hood: true,  face: true,  neck: true,  vest: false, shirt: false, coat: false, pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  magic_lizard_part: true },
    coat:          { helmet: true,  helmet_big: true,  helmet_visor: true,  hood: true,  face: true,  neck: true,  vest: false, shirt: false, coat: false, pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  magic_lizard_part: true },
    pants:         { helmet: true,  helmet_big: true,  helmet_visor: true,  hood: true,  face: true,  neck: true,  vest: true,  shirt: true,  coat: true,  pants: false, footwear: true,  gloves: true,  shorts: false, skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  magic_lizard_part: true },
    footwear:      { helmet: true,  helmet_big: true,  helmet_visor: true,  hood: true,  face: true,  neck: true,  vest: true,  shirt: true,  coat: true,  pants: true,  footwear: false, gloves: true,  shorts: true,  skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  magic_lizard_part: true },
    gloves:        { helmet: true,  helmet_big: true,  helmet_visor: true,  hood: true,  face: true,  neck: true,  vest: true,  shirt: true,  coat: true,  pants: true,  footwear: true,  gloves: false, shorts: true,  skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  magic_lizard_part: true },
    shorts:        { helmet: true,  helmet_big: true,  helmet_visor: true,  hood: true,  face: true,  neck: true,  vest: true,  shirt: true,  coat: true,  pants: false, footwear: true,  gloves: true,  shorts: false, skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  magic_lizard_part: true },
    skirt:         { helmet: true,  helmet_big: true,  helmet_visor: true,  hood: true,  face: true,  neck: true,  vest: true,  shirt: true,  coat: true,  pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: false, stocking_suit: true,  robe: true,  cloack: true,  magic_lizard_part: true },
    stocking_suit: { helmet: true,  helmet_big: true,  helmet_visor: true,  hood: true,  face: true,  neck: true,  vest: true,  shirt: true,  coat: true,  pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: true,  stocking_suit: false, robe: true,  cloack: true,  magic_lizard_part: true },
    robe:          { helmet: true,  helmet_big: true,  helmet_visor: true,  hood: true,  face: true,  neck: true,  vest: true,  shirt: true,  coat: true,  pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: true,  stocking_suit: false, robe: false, cloack: true,  magic_lizard_part: true },
    cloack:        { helmet: true,  helmet_big: true,  helmet_visor: true,  hood: true,  face: true,  neck: true,  vest: true,  shirt: true,  coat: true,  pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: true,  stocking_suit: false, robe: true,  cloack: false, magic_lizard_part: true },
    magic_lizard_part:   { helmet: true,  helmet_big: true,  helmet_visor: true,  hood: true,  face: true,  neck: true,  vest: true,  shirt: true,  coat: true,  pants: true,  footwear: true,  gloves: true,  shorts: true,  skirt: true,  stocking_suit: true,  robe: true,  cloack: true,  magic_lizard_part: true }
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

  # --- CLASS DATA ACCESS ---
  def self.data; DATA; end
  def self.kinds; DATA.keys; end

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



  # --- RAND ENGINE OVERRIDE ---

  def self.randomize(level_depth, args)
    Item.randomize(level_depth, self, args)
  end

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