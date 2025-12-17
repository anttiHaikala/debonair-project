class Wand < Item
  attr_accessor :charges
  attr_accessor :known_to_be_empty

  def initialize(kind, args)
    super(kind, :wand)
    @charges = 3 + args.state.rng.rand(5) # 3 to 7 charges
    @known_to_be_empty = false
  end

  def self.kinds
  [
    :wand_of_magic_missile,
    :wand_of_fireball,
    :wand_of_healing,
    :wand_of_lightning,
    :wand_of_slowing,
    :wand_of_digging,
    :wand_of_polymorph,
    :wand_of_teleportation,
    # :wand_of_death
  ]
  end

  def self.masks
    [
      :birch,
      :oak,
      :ebony,
      :willow,
      :maple,
      :pine,
      :mahogany,
      :bone,
      :ivory,
      :glass
      ]
  end

  def title(args)
    mask_index = Wand.kinds.index(self.kind) % Wand.masks.length
    mask = Wand.masks[mask_index]
    args.state.hero.known_wands ||= []
    charge_status = @known_to_be_empty ? "drained " : ""
    if args.state.hero.known_wands.include?(self.kind)
      "#{charge_status}" + "#{self.attributes.join(' ')} #{mask} wand (#{self.kind.to_s.gsub('wand_of_','')})".trim
    else
      "#{mask} wand".trim
    end
  end

  def self.randomize(level_depth, args)
    kind = args.state.rng.choice(self.kinds)
    return Wand.new(kind, args)
  end

  def identify(args)
    args.state.hero.known_wands ||= []
    unless args.state.hero.known_wands.include?(self.kind)
      args.state.hero.known_wands << self.kind
    end
  end
    
  def use(entity, args)
    if entity.wielded_items.include?(self)
      HUD.output_message(args, "You unwield the #{self.attributes.join(' ')} #{self.kind.to_s.gsub('_',' ')}.".gsub('  ',' '))
      entity.wielded_items.delete(self)
    else
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
      SoundFX.play(:blade, args) # TODO: different sound for different item types
    end
    args.state.kronos.spend_time(entity, entity.walking_speed * 0.5, args) 
  end

  def self.zap_with(user, wand, target_x, target_y, target_entity=nil, args)
    if wand.charges <= 0
      wand.known_to_be_empty = true
      HUD.output_message(args, "The #{wand.title(args)} has no charges left!")
      return
    end
    wand.charges -= 1
    wand.identify(args)
    SoundFX.play(wand.kind.to_s.gsub('wand_of_',''), args)
    case wand.kind
    when :wand_of_magic_missile
      Wand.cast_magic_missile(user, target_x, target_y, target_entity, args)
    when :wand_of_fireball
      Wand.cast_fireball(user, target_x, target_y, target_entity, args)
    when :wand_of_healing
      Wand.cast_healing(user, target_x, target_y, target_entity, args)
    when :wand_of_lightning
      Wand.cast_lightning_bolt(user, target_x, target_y, target_entity, args)
    when :wand_of_slowing
      Wand.cast_slowing(user, target_x, target_y, target_entity, args)
    when :wand_of_digging
      Wand.cast_digging(user, target_x, target_y, target_entity, args)
    when :wand_of_polymorph
      Wand.cast_polymorph(user, target_x, target_y, target_entity, args)
    when :wand_of_teleportation
      Wand.cast_teleportation(user, target_x, target_y, target_entity, args)
    else
      HUD.output_message(args, "The #{wand.title(args)} does nothing.")
    end
  end

  def self.cast_magic_missile(user, target_x, target_y, target_entity, args)
    HUD.output_message(args, "#{user.name} zaps a magic missile towards (#{target_x}, #{target_y})!")
    if target_entity
      number_of_wounds = 1 + args.state.rng.rand(3) # 1 to 3 missiles
      number_of_wounds.times do
        hit_location = target_entity.random_body_part(args)
        severity_modifier = 0
        severity = Wand.roll_severity(severity_modifier, args)
        Trauma.inflict(target_entity, hit_location, :magic, severity, args)
      end
      HUD.output_message(args, "The magic missile hits #{target_entity.name} #{number_of_wounds} times")
    else
      HUD.output_message(args, "The magic missile flies off into the distance.")
    end
  end

  def self.cast_healing(user, target_x, target_y, target_entity, args)
    HUD.output_message(args, "#{user.name} zaps a healing spell!")
    if target_entity
      effect = 0
      Trauma.active_traumas(target_entity).each do |trauma|
        roll = args.state.rng.d12 
        if roll >= trauma.numeric_severity
          trauma.heal_one_step
          effect += 1
        end
      end
      if effect > 0
        HUD.output_message(args, "The healing spell heals #{target_entity.name}!")
      else
        HUD.output_message(args, "The healing spell has no effect on #{target_entity.name}.")
      end
    else
      HUD.output_message(args, "The healing spell hits nothing.")
    end
    effect = Effect.new(:heal, target_x, target_y, 1.0)
    args.state.dungeon.levels[user.depth].effects << effect
    SoundFX.play_sound_xy(:heal, target_x, target_y, args)
  end

  def self.cast_lightning_bolt(user, target_x, target_y, target_entity, args)
    HUD.output_message(args, "#{user.name} zaps a lightning bolt towards (#{target_x}, #{target_y})!")
    if target_entity
      number_of_wounds = 1 + args.state.rng.rand(2) # 1 to 3 missiles
      number_of_wounds.times do
        hit_location = target_entity.random_body_part(args)
        severity_modifier = 5
        severity = Wand.roll_severity(severity_modifier, args)
        Trauma.inflict(target_entity, hit_location, :electric, severity, args)
      end
      HUD.output_message(args, "The lightining bolt hits #{target_entity.name}!")
    else
      HUD.output_message(args, "The lightining bolt hits nothing.")
    end
    eff = Effect.new(:lightning, target_x, target_y, 0.5)
    args.state.dungeon.levels[user.depth].effects << eff
    SoundFX.play_sound_xy(:lightning, target_x, target_y, args)    
  end

  def self.cast_fireball(user, target_x, target_y, target_entity, args)
    HUD.output_message(args, "#{user.name} casts a ball of fire!")
    if target_entity
      number_of_wounds = 1 + args.state.rng.rand(2) 
      number_of_wounds.times do
        hit_location = target_entity.random_body_part(args)
        severity_modifier = 2
        severity = Wand.roll_severity(severity_modifier, args)
        Trauma.inflict(target_entity, hit_location, :burn, severity, args)
      end
      HUD.output_message(args, "The ball of fire hits #{target_entity.title(args)}!")
    else
      HUD.output_message(args, "The ball of fire hits nothing.")
    end
    # add fire effect
    effect = Effect.new(:fire, target_x, target_y, 1.5)
    args.state.dungeon.levels[user.depth].effects << effect
    # sound
    SoundFX.play("fireball", args)
  end

  def self.cast_digging(user, target_x, target_y, target_entity, args)
    HUD.output_message(args, "#{user.name} zaps a digging spell!")
    level = args.state.dungeon.levels[user.depth]    
    # create a vector from user to target
    dx = target_x - user.x
    dy = target_y - user.y
    distance = Math.sqrt(dx*dx + dy*dy)
    range = 5 + args.state.rng.d6 - 1
    # dig all the tiles between user and target within range
    (1..range).each do |i|
      printf "Digging step %d/%d\n" % [i, range]
      t_x = user.x + (dx * i / distance).round
      t_y = user.y + (dy * i / distance).round
      if t_x >= 0 && t_x < level.width && t_y >= 0 && t_y < level.height
        level.tiles[t_y][t_x] = :floor
        # add dig effect
        effect = Effect.new(:dig, t_x, t_y, 0.20)
        args.state.dungeon.levels[user.depth].effects << effect
      end
    end
    SoundFX.play_sound_xy(:dig, target_x, target_y, args)
  end

  def self.cast_slowing(user, target_x, target_y, target_entity, args)
    HUD.output_message(args, "#{user.name} zaps a slowing spell!")
    if target_entity
      status = Status.new(target_entity, :slowed, 20, args)
      target_entity.add_status(status)
      HUD.output_message(args, "#{target_entity.title(args)} is slowed down!")
    else
      HUD.output_message(args, "The slowing spell hits nothing.")
    end
    SoundFX.play_sound_xy(:slow, target_x, target_y, args)
  end

  def self.cast_teleportation(user, target_x, target_y, target_entity, args)
    HUD.output_message(args, "#{user.name} zaps a teleportation spell!")
    if target_entity
      HUD.output_message(args, "#{target_entity.title(args)} vanishes in a flash of light!")
      target_entity.teleport(args)
    else
      # is there an item? to teleport if no entity?
      level = args.state.dungeon.levels[user.depth]
      item = level.item_at(target_x, target_y)
      if item
        HUD.output_message(args, "The #{item.title(args)} vanishes in a flash of light!")
        item.teleport(args)
      else
        HUD.output_message(args, "The teleportation spell hits nothing.")
      end
    end
    SoundFX.play(:teleport, args)
  end

  def self.cast_polymorph(user, target_x, target_y, target_entity, args)
    HUD.output_message(args, "#{user.name} zaps a polymorph spell!")
    if target_entity
      old_species = target_entity.species
      new_species = args.state.rng.choice(Species.npc_species)
      target_entity.species = new_species
      HUD.output_message(args, "#{target_entity.title(args)} is transformed from #{old_species} to #{new_species}!")
    else
      HUD.output_message(args, "The polymorph spell hits nothing.")
    end
    SoundFX.play_sound_xy(:polymorph, target_x, target_y, args)
  end

  def self.cast_clone(user, target_x, target_y, target_entity, args)
    HUD.output_message(args, "#{user.name} zaps a cloning spell towards (#{target_entity.title(args)})!")
    if target_entity
      clone = target_entity.clone_entity(args)
      level = args.state.dungeon.levels[user.depth]
      clone.x = target_entity.x + 1
      clone.y = target_entity.y
      level.entities << clone
      HUD.output_message(args, "A clone of #{target_entity.title(args)} appears!")
    else
      HUD.output_message(args, "The cloning spell hits nothing.")
    end
    SoundFX.play_sound_xy(:clone, target_x, target_y, args)
  end


  def self.roll_severity(severity_modifier, args)
    # roll for severity
    severity_roll = args.state.rng.d20 + severity_modifier
    case severity_roll
    when 1..10
      return :minor
    when 11..15
      return :moderate
    when 16..19
      return :severe
    when 20..Float::INFINITY
      return :critical
    end
  end

end
