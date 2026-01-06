class Weapon < Item
  DATA = {
    dagger: {
      damage: 4, defense: 1, melee: 3, inaccuracy: 3, hit_kind: :cut,
      meta: { ui_name: "dagger", break_treshold: 11, material: :metal, weight: 0.4, range: 1, throwable: true, ranged: false, price: 10, occurance: 1.0 }
    },
    razor_blade: {
      damage: 3, defense: 0, melee: 3, inaccuracy: 3,  hit_kind: :cut,
      meta: { ui_name: "razor blade", break_treshold: 9, material: :metal, weight: 0.1, range: 0, throwable: true, ranged: false, price: 5, occurance: 0.5 }
    },
    sword: {
      damage: 8, defense: 3, melee: 4, inaccuracy: 4, hit_kind: :cut,
      meta: { ui_name: "sword", break_treshold: 12, material: :metal, weight: 1.5, range: 0, throwable: false, ranged: false, price: 50, occurance: 0.8 }
    },
    katana: {
      damage: 10, defense: 2, melee: 5, inaccuracy: 5, hit_kind: :cut,
      meta: { ui_name: "katana", break_treshold: 12, material: :metal, weight: 1.3, range: 0, throwable: false, ranged: false, price: 200, occurance: 0.2 }
    },
    axe: {
      damage: 9, defense: 1, melee: 3, inaccuracy: 3, hit_kind: :cut,
      meta: { ui_name: "axe", break_treshold: 10, material: :metal, weight: 2.0, range: 1, throwable: true, ranged: false, price: 30, occurance: 0.7 }
    },
    mace: {
      damage: 7, defense: 2, melee: 4, inaccuracy: 5, hit_kind: :blunt,
      meta: { ui_name: "mace", break_treshold: 12, material: :metal, weight: 2.5, range: 0, throwable: false, ranged: false, price: 35, occurance: 0.7 }
    },
    club: {
      damage: 6, defense: 2, melee: 3, inaccuracy: 5, hit_kind: :blunt,
      meta: { ui_name: "club", break_treshold: 8, material: :organic, weight: 2.2, range: 0, throwable: true, ranged: false, price: 2, occurance: 1.0 }
    },
    spear: {
      damage: 7, defense: 4, melee: 4, inaccuracy: 3, hit_kind: :pierce,
      meta: { ui_name: "spear", break_treshold: 8, material: :organic, weight: 1.8, range: 2, throwable: true, ranged: false, price: 20, occurance: 0.6 }
    },
    staff: {
      damage: 4, defense: 5, melee: 2, inaccuracy: 5, hit_kind: :blunt,
      meta: { ui_name: "staff", break_treshold: 8, material: :organic, weight: 1.5, range: 0, throwable: false, ranged: false, price: 5, occurance: 0.8 }
    },
    whip: {
      damage: 5, defense: 0, melee: 1, inaccuracy: 5,  hit_kind: :blunt,
      meta: { ui_name: "whip", break_treshold: 7, material: :organic, weight: 0.8, range: 2, throwable: false, ranged: false, price: 15, occurance: 0.3 }
    },
    selfie_stick: {
      damage: 2, defense: 1, melee: 1, inaccuracy: 6,  hit_kind: :blunt,
      meta: { ui_name: "selfie stick", break_treshold: 7, material: :syntethic, weight: 0.3, range: 0, throwable: false, ranged: false, price: 50, occurance: 0.1 }
    },
    bow: {
      damage: 6, defense: 0, melee: 0, inaccuracy: 2,  hit_kind: :pierce,
      meta: { ui_name: "bow", break_treshold: 11, material: :organic, weight: 1.0, range: 10, ammo: :arrow, throwable: false, ranged: true, price: 80, occurance: 0.5 }
    },
    crossbow: {
      damage: 6, defense: 0, melee: 1, inaccuracy: 1,  hit_kind: :pierce,
      meta: { ui_name: "crossbow", break_treshold: 11, material: :organic, weight: 1.0, range: 10, ammo: :arrow, throwable: false, ranged: true, price: 80, occurance: 0.5 }
    },
    sling: {
      damage: 4, defense: 0, melee: 0, inaccuracy: 3,  hit_kind: :blunt,
      meta: { ui_name: "sling", break_treshold: 13, material: :organic, weight: 1.0, range: 10, ammo: :stone, throwable: false, ranged: true, price: 80, occurance: 0.5 }
    },
    shuriken: {
      damage: 3, defense: 0, melee: 0, inaccuracy: 2,   hit_kind: :cut,
      meta: { ui_name: "shuriken", break_treshold: 10, material: :metal, weight: 0.1, range: 5, throwable: true, ranged: true, price: 2, occurance: 0.4 }
    },
    revolver: {
      damage: 15, defense: 0, melee: 0, inaccuracy: 0,  hit_kind: :pierce,
      meta: { ui_name: "revolver", break_treshold: 12, material: :metal, weight: 1.2, range: 8, ammo: :bullet, throwable: false, ranged: true, price: 500, occurance: 0.1 }
    },
    raygun: {
      damage: 25, defense: 0, melee: 0, inaccuracy: -1,   hit_kind: :burn,
      meta: { ui_name: "raygun", break_treshold: 13, material: :synthetic, weight: 1.5, range: 12, ammo: :battery_pack, throwable: false, ranged: true, price: 5000, occurance: 0.01 }
    },
    wooden_shield: {
      damage: 1, defense: 3, melee: 1, inaccuracy: 7,   hit_kind: :burn,
      meta: { ui_name: "wooden shield", break_treshold: 8, material: :organic, weight: 4, range: 1, throwable: false, ranged: false, price: 10, occurance: 1.0 }
    },
    bronze_shield: {
      damage: 1, defense: 6, melee: 1, inaccuracy: 7,   hit_kind: :burn,
      meta: { ui_name: "bronze", break_treshold: 13, material: :organic, weight: 8, range: 1, throwable: false, ranged: false, price: 100, occurance: 0.1 }
    }
  }

  attr_accessor :damage, :defense, :melee, :inaccuracy, :hit_kind, :meta

  def initialize(kind, args = nil, &block) 

    blueprint = DATA[kind] || {damage: 1, defense: 0, melee: 3, inaccuracy: 3, meta: {} }
    
    # Initialize from blueprint
    @meta = blueprint[:meta].dup
    
    @damage  = blueprint[:damage] || 1
    @defense = blueprint[:defense] || 0
    @melee = blueprint[:melee] || 3
    @inaccuracy_penalty = blueprint[:inaccuracy] || 5
    @hit_kind = blueprint[:hit_kind] || :cut
    @weight  = @meta[:weight] || 0.6
    @break_threshold = @meta[:break_threshold] || 11
    super(kind, :weapon, &block)
    
  end

  # --- CLASS DATA ACCESS ---
  def self.data; DATA; end
  def self.kinds; DATA.keys; end

  def self.common_attributes
    [:rusty, :moldy, :broken, :fine, :crude, :balanced, :heavy, :light, :expensive, :enchanted, :rotten]
  end

  def self.rare_attributes
    [:masterwork, :soul_consuming, :mythical, :holy, :demon_slayer, :alien_made]
  end

  # --- ATTRIBUTE LOGIC ---

  def apply_attribute_modifiers(args, attribute)
    case attribute
    when :rusty, :moldy, :rotten
      @damage = [@damage - 2, 1].max
      @melee -=2
      @break_threshold -=2
    when :broken
      @damage = (@damage * 0.5).floor
      @defense -= 2
      @melee -= 2
    when :fine, :balanced
      @damage += 1
      @defense += 1
      @melee += 3
    when :crude
      @damage = [@damage - 1, 1].max
      @melee -= 2
      @break_threshold -=1
    when :cursed
      @damage = [@damage - 1, 1].max
      @melee -= 3
    when :enchanted
      @damage += 3
      @melee += 3
    when :masterwork, :mythical, :holy, :demon_slayer, :enchanted, :soul_consuming
      # Increase damage significantly; if args is present, roll for the bonus
      # Add indiviudal expectional attributes later 
      bonus = args ? args.state.rng.nxt_int(2, 4) : 3
      @damage += bonus
      @defense += 1
      @melee += 4
      @break_threshold +=2
    when :expensive
      @meta[:price] = (@meta[:price] * 2).to_i
    when :alien_made
      @damage += 10
      @weight *= 0.5
    end
  end

  # --- ACCESSORS & FLAGS ---

  def weapon_material; @meta[:material]; end
  
  def is_ranged?; @meta[:ranged] == true; end
  def is_throwable?; @meta[:throwable] == true; end
  
  def range; @meta[:range] || 0; end
  def ammo_type; @meta[:ammo]; end

  # --- RAND ENGINE OVERRIDE ---

  def self.randomize(level_depth, args)
    Item.randomize(level_depth, self, args)
  end

  def use(entity, args)
    if entity.wielded_items.include?(self)
      HUD.output_message(args, "You unwield the #{self.attributes.join(' ')} #{self.kind.to_s.gsub('_',' ')}.".gsub('  ',' '))
      entity.wielded_items.delete(self)
    else
      # special case: if wielding a weapon and an off-hand item, replace the weapon with this one
      if entity.wielded_items.size == 2 && entity.wielded_items[0].category == :weapon && entity.wielded_items[1].category != :weapon
        entity.wielded_items[0] = self
        HUD.output_message(args, "You switch to wielding the #{self.title(args)}.")
        return
      end
      # add to beginning of array
      entity.wielded_items = [self] + entity.wielded_items
      if entity.wielded_items.length > 2
        entity.wielded_items = entity.wielded_items[0..1]
      end
      HUD.output_message(args, "You wield the #{self.title(args)}.")
      SoundFX.play(:blade, args) # TODO: different sound for different weapon types
    end
    args.state.kronos.spend_time(entity, entity.walking_speed * 0.5, args) 
  end

  def self.generate_for_npc(npc, depth, args)
    case npc.species
    when :goblin
      weapon = Weapon.new(:dagger)
      weapon.add_attribute(:crude)
    when :orc
      weapon = Weapon.new(:axe)
      weapon.add_attribute(:crude)
    when :skeleton
      weapon = Weapon.new(:sword)
      weapon.add_attribute(:rusty)
    else
      weapon = Weapon.randomize(depth, args)
    end
    return weapon
  end

  def break_check(args)
    roll = args.state.rng.d20
    break_threshold = 11
    if self.attributes.include?(:broken)
      return
    end
    if self.attributes.include?(:masterwork)
      break_threshold += 8
    end
    if self.attributes.include?(:fine)
      break_threshold += 5
    end
    if self.attributes.include?(:crude) || self.attributes.include?(:rusty)
      break_threshold -= 3
    end
    if roll >= break_threshold
      HUD.output_message(args, "Your #{self.title(args)} breaks!")
      SoundFX.play_sound(:item_break, args)
      self.add_attribute(:broken)
    end
  end
end



