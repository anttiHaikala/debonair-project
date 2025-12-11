class Armor < Item
  def initialize(kind)
    super(kind, :armor)
  end

  def self.kinds
    return [
      :leather_armor_shirt,
      :leather_armor_pants,
      :chain_mail_shirt,
      :chain_mail_tank_top,
      :full_plate_mail, # the full suit :p, takes forever to put on or take off
      :lamellar_armor_shirt,
      :lamellar_armor_pants,
      :armet, # fully enclosed helmet - disallows eating unless it can be opened
      :bascinet, # open helmet that protects sides and back of head
      :gorget, # neck armor that can be worn with helmets
      :kabuto, # samurai helmet
      :menpo # samurai face armor - can't eat wearing this item
    ]
  end

  def self.randomize(depth, args)
    kind = args.state.rng.choice(self.kinds)
    return Armor.new(kind)
  end

  def body_parts_covered
    case self.kind
    when :leather_armor_shirt, :chain_mail_shirt, :lamellar_armor_shirt
      return [:upper_torso, :left_arm, :right_arm]
    when :leather_armor_pants
      return [:left_leg, :right_leg, :lower_torso]
    when :chain_mail_tank_top
      return [:upper_torso]
    when :full_plate_mail
      return [:lower_torso, :upper_torso, :left_arm, :right_arm, :left_leg, :right_leg]
    when :armet, :bascinet
      return [:head]
    when :gorget
      return [:neck]
    when :kabuto
      return [:head]
    when :menpo
      return [:face]
    else
      return []
    end
  end 

  def use(user, args)
    if user != args.state.hero
      return
    end
    unless user.worn_items.include?(self)
      user.worn_items << self
      HUD.output_message(args,"You put on the #{self.title(args)}.")
    else
      user.worn_items.delete(self)
      HUD.output_message(args,"You take off the #{self.title(args)}.")
    end
  end
end