# traps are placed on the level and trigger when an entity steps on them
class Trap
  attr_reader :x, :y, :kind, :level
  attr_accessor :found
  attr_accessor :knowers # entities that know about this trap. knowers know!
  def initialize(x, y, kind, level)
    @x = x
    @y = y
    @kind = kind
    @level = level
    @found = false
    @target_x = nil
    @target_y = nil
    @knowers = []
  end

  def self.kinds
    return [:spike, :fire, :poison_dart, :teleportation, :trapdoor]
    # return [:spike, :fire, :poison_dart, :rock, :sleep_gas, :bear_trap, :teleportation, :pit, :trapdoor]
  end

  def title args
    return "%s trap" % [@kind.to_s.gsub('_',' ')]
  end

  def self.trigger_trap_at(entity, x, y, args)
    level = Utils.level_by_depth(entity.depth, args)
    level.traps.each do |trap|
      if trap.x == x && trap.y == y
        trap.trigger(entity, args)
      end
    end
  end

  def is_known_by(entity)
    @knowers.each do |knower|
      if knower == entity
        return true
      end
    end
    return false
  end

  def learn(entity)
    self.knowers << entity unless self.is_known_by(entity)
  end

  def trigger entity, args
    # base trigger chance: 80%
    # TODO: this could also be trap-specific (some traps harder to trigger etc)
    trigger_chance = 80
    if args.state.rng.rand(100) >= trigger_chance
      # trap did not trigger
      if args.state.hero.sees?(entity, args)
        HUD.output_message args, "#{entity.name} passes a #{@kind.to_s.gsub('_',' ')} trap but it does not trigger!"
      end
      return
    end

    # avoidance chance if known trap
    if self.is_known_by(entity)
      avoidance_chance = 50
      if args.state.rng.rand(100) < avoidance_chance
        # avoided the trap
        HUD.output_message args, "#{entity.name} avoids a #{@kind.to_s.gsub('_',' ')} trap!"
        return
      end
    end
    
    # anyone who sees the trap go off, learns about it
    level = Utils.level_by_depth(entity.depth, args)
    level.entities.each do |e|
      if e.sees?(entity, args)
        self.learn(e)
      end
    end

    # and just to make sure, the entity itself always learns about it
    self.learn(entity)

    # if hero triggered it, add input cooldown
    if entity == args.state.hero
      GUI.add_input_cooldown(30)
    end
    printf "%s triggered a %s trap at (%d,%d)!\n" % [entity.name, @kind.to_s.gsub('_',' '), @x, @y]

    # hey, only say it's found if the hero sees it!
    @found = true # deprecate the found attribute later

    case @kind
    when :spike
      amount_of_spikes = 1 + (args.state.rng.rand(3))
      amount_of_spikes.times do
        body_part = entity.random_body_part(args)
        hit_severity = Trauma.severities[1 + args.state.rng.rand(3)] # skip the healed one
        hit_kind = :pierce
        Trauma.inflict(entity, body_part, hit_kind, hit_severity, args)
        SoundFX.play_sound(:hero_hurt, args)
      end
      HUD.output_message args, "#{entity.name} is impaled by #{amount_of_spikes} spikes!"
    when :poison_dart
      Status.new(entity, :poisoned, 10 + args.state.rng.d10, args)
      SoundFX.play_sound(:hero_hurt, args)
      HUD.output_message args, "#{entity.name} is poisoned by a poison dart!"
    when :fire
      SoundFX.play("fireball", args)
      level = Utils.level(args)
      height = level.height
      width = level.width
      radius = [args.state.rng.d6 - 1, 1].max
      (self.x - radius).upto(self.x + radius) do |x|
        (self.y - radius).upto(self.y + radius) do |y|
          if x < 0 || x >= width || y < 0 || y >= height
            next
          end
          # damage entities straight up for now (later to it in fire mechanism)
          if Math.sqrt((x - self.x)**2 + (y - self.y)**2) <= radius
            # add fire to the tile
            level.add_effect(:fire, x, y, args)
            target = Tile.entity_at(x, y, args)
            if target 
              amount_of_burns = Numeric.rand(1..3)
              amount_of_burns.times do
                body_part = target.random_body_part(args) 
                severity = Trauma.severities[Numeric.rand(1..4)] # skip the healed one
                HUD.output_message args, "The #{body_part} of #{target.species} suffers #{severity} burns!"
                Trauma.inflict(target, body_part, :burn, severity, args)            
              end
            end
          end
        end
      end

    # when :rock
    # when :sleep_gas
    # when :bear_trap, :pit etc

    when :teleportation
      HUD.output_message args, "#{entity.name} steps on a teleportation trap!"
      entity.teleport(args)
    when :trapdoor
      # check for last level
      if entity.depth >= args.state.dungeon.max_depth - 1
        HUD.output_message args, "#{entity.name} steps on a trapdoor but it doesn't lead anywhere! Bedrock reached."
        return
      end
      HUD.output_message args, "#{entity.name} falls through a trapdoor to the level below!"
      Utils.move_entity_to_level(entity, entity.depth + 1, args)
      @target_x = entity.x
      @target_y = entity.y
    end
  end

  def self.populate_for_level(level, args)
    # place traps randomly in the level
    number_of_traps = args.state.rng.rand(6) + (level.depth/2).floor - 2
    if number_of_traps < 0
      number_of_traps = 0
    end
    traps_installed = 0
    safety = 0
    while traps_installed < number_of_traps
      safety += 1
      if safety > 1000
        printf "Could not place all traps on level %d - placed %d out of %d\n" % [level.depth, traps_installed, number_of_traps]
        break
      end
      x = args.state.rng.rand(level.width)
      y = args.state.rng.rand(level.height)
      # check if the tile is already taken by another trap
      exiting_trap_in_the_same_spot = false
      level.traps.each do |existing_trap|
        if existing_trap.x == x && existing_trap.y == y
          exiting_trap_in_the_same_spot = true
          break
        end
      end
      next if exiting_trap_in_the_same_spot
      tile = level.tiles[y][x]
      # only floor tiles can have traps - no staircases, water etc
      next unless tile == :floor
      # we can place a trap, yes!
      kind = Trap.kinds.sample
      trap = Trap.new(x, y, kind, level)
      level.traps << trap
      traps_installed += 1
    end
    printf "Placed %d traps on level %d\n" % [traps_installed, level.depth]
  end

  def self.draw_traps args
    level = Utils.level(args)
    level.traps.each do |trap|
      if trap.found
        x = trap.x
        y = trap.y
        tile_size = Utils.tile_size(args)
        sprite_tile_size = 16
        if Utils.within_viewport?(x, y, args)
          #draw it
          screen_x = Utils.offset_x(args) + x * tile_size
          screen_y = Utils.offset_y(args) + y * tile_size
          args.outputs.sprites << {
            x: screen_x, y: screen_y, w: tile_size, h: tile_size  , 
            path: "sprites/sm16px.png",
            source_x: sprite_tile_size * 8, source_y: sprite_tile_size * 5, source_w: sprite_tile_size, source_h: sprite_tile_size
          }
        end
      end
    end
  end

  def self.disarm_trap_at(hero, x, y, level, args)
    # TODO: needed_to_disarm could depend on trap instance 
    # TODO: some tools could help disarming traps
    trap_to_disarm = nil
    level.traps.each do |trap|
      if trap.x == x && trap.y == y
        trap_to_disarm = trap
        break
      end
    end
    if trap_to_disarm
      die_roll = args.state.rng.d20
      needed_to_disarm = 10
      case hero.role
      when :thief, :detective
        needed_to_disarm -= 4
      when :ninja, :rogue
        needed_to_disarm -= 2
      when :warrior, :tourist, :monk, :druid, :wizard, :cleric
        needed_to_disarm += 2
      end
      if hero.age == :elder
        needed_to_disarm += 1
      end
      if die_roll >= needed_to_disarm
        level.traps.delete(trap_to_disarm)
        HUD.output_message args, "#{hero.name} successfully disarmed the #{trap_to_disarm.title(args)}."
        SoundFX.play_sound(:trap_disarmed, args)
      else
        HUD.output_message args, "#{hero.name} failed to disarm the #{trap_to_disarm.title(args)} and triggered it!"
        trap_to_disarm.trigger(hero, args)
      end
    else
      HUD.output_message args, "No trap found at that location to disarm."
    end
  end
end