# never instantiated
class Combat
  def self.resolve_attack(attacker, defender, args)
    aname = attacker.name
    dname = defender.name
    # simple attack logic
    base_attack_roll = args.state.rng.d20
    to_hit = 5
    attack_roll = base_attack_roll
    if defender.has_status?(:shock)
      to_hit += 10
    end
    weapon_modifier = 0
    if attacker.wielded_items
      attacker.wielded_items.each do |item|
        if item.category == :weapon
          weapon_modifier = 3 # base for all weapons
        end
        if item.attributes.include?(:fine)
          weapon_modifier += 2
        elsif item.attributes.include?(:rusty) 
          weapon_modifier -= 2
        elsif item.attributes.include?(:crude)
          weapon_modifier -= 1
        elsif item.attributes.include?(:masterwork)
          weapon_modifier += 4
        elsif item.attributes.include?(:legendary)
          weapon_modifier += 6
        elsif item.attributes.include?(:cursed)
          weapon_modifier -= 3
        elsif item.attributes.include?(:broken)
          weapon_modifier -= 4
        end
      end
    end
    if attacker.worn_items
      attacker.worn_items.each do |item|
        if item.kind == :ring_of_accuracy
          attack_roll += 5
        end
      end
    end
    attack_roll += weapon_modifier
    # does it even hit?
    if base_attack_roll < to_hit 
      HUD.output_message args, "#{aname} attacks #{dname} but misses."
      SoundFX.play_sound(:miss, args)
      return # miss
    end
    # defender attempts to dodge
    if !attacker.invisible? && !defender.has_status?(:shock)
      dodge_roll = args.state.rng.d20
      dodge_roll -= 3 # just to make it a bit less likely to dodge  
      if dodge_roll > attack_roll
        HUD.output_message args, "#{aname} attacks #{dname} but #{dname} dodges."
        SoundFX.play_sound(:miss, args)
        return # dodged
      end
    end
    # hit!
    hit_location = defender.random_body_part(args)
    hit_severity = self.hit_severity(attacker, defender, attack_roll, args)
    hit_kind = :bruise
    Trauma.inflict(defender, hit_location, hit_kind, hit_severity, args)
    SoundFX.play_sound(:hit, args)
    HUD.output_message args, "#{aname} bruises #{dname}'s #{hit_location.to_s.gsub('_', ' ')} #{hit_severity}ly."
    defender_shocked = Trauma.determine_shock(defender)
    if defender_shocked
      defender.add_status(:shock)
      HUD.output_message args, "#{dname} is in shock from trauma!"
    end
    # todo: inflict "shaken" effects to make the target miss some time due to receiving trauma
    defender_dead = Trauma.determine_morbidity(defender)
    printf "Defender dead?=: %s, Defender wound count: %d\n" % [defender_dead.to_s, defender.traumas.size]
    if defender_dead
      HUD.output_message args, "#{dname} has died!"
      if defender == args.state.run.hero
        HUD.output_message args, "Press A to continue..."
        args.state.hero.perished = true
        args.state.hero.reason_of_death = "in combat against #{aname}"
        return
      else
        SoundFX.play_sound(:npc_death, args)
        # remove defender from level
        level = args.state.dungeon.levels[defender.level]
        level.entities.delete(defender)
      end
    else
      if defender == args.state.run.hero
        GUI.flash_screen(:red, args)
        SoundFX.play_sound(:hero_hurt, args)
      else
        SoundFX.play_sound(:npc_hurt, args)
      end
    end    
  end

  def self.hit_severity(attacker, defender, attack_roll, args)
    severity_modifier = 0
    weapon_modifier = 0
    if attacker.wielded_items
      attacker.wielded_items.each do |item|
        if item.category == :weapon
          weapon_modifier = 3 # base for all weapons
        end
        if item.attributes.include?(:fine)
          weapon_modifier += 2
        elsif item.attributes.include?(:rusty) 
          weapon_modifier -= 2
        elsif item.attributes.include?(:crude)
          weapon_modifier -= 1
        elsif item.attributes.include?(:masterwork)
          weapon_modifier += 4
        elsif item.attributes.include?(:legendary)
          weapon_modifier += 6
        elsif item.attributes.include?(:cursed)
          weapon_modifier -= 3
        elsif item.attributes.include?(:broken)
          weapon_modifier -= 4
        end
      end
    end
    severity_modifier += weapon_modifier
    if attacker.worn_items
      attacker.worn_items.each do |item|
        if item.kind == :ring_of_strength
          severity_modifier += 5
        end
      end
    end
    if attack_roll == 20
      # natural 20, critical hit
      severity_modifier += 5
    end
    # defender's items
    if defender.worn_items
      defender.worn_items.each do |item|
        if item.kind == :ring_of_protection
          severity_modifier -= 5
        end
      end
    end
    # roll for severity
    severity_roll = args.state.rng.d20 + severity_modifier
    case severity_roll
    when 1..8
      return :minor
    when 9..14
      return :moderate
    when 15..18
      return :severe
    when 19..Float::INFINITY
      return :critical
    end
  end
end