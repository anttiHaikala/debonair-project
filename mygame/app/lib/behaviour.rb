# class the NPC behaviours
# 
# interaction behaviours like attack, escape
# movement behaviours like patrol, wander, follow, flee
# 
# flee or fight decision making
# love / hate relationships
# ally / enemy relationships
# hunting behaviour
# eating behaviour
# foraging behaviour
# pack behaviour
# herding behaviour
# social hierarchy behaviour
# territorial behaviour
# sleeping behaviour
# mating behaviour
# nurturing behaviour
# curiosity behaviour
# exploration behaviour
# hiding behaviour
# stay away from hero 

class Behaviour

  attr_accessor :destination, :kind, :npc

  def initialize(kind, npc)
    @kind = kind
    @npc = npc              # subject of the behaviour
    @destination = nil      # destionation of activity as x, y, depth coordinates
    @target = nil           # object of the behaviour
  end

  def self.setup_for_npc(npc)
    species = npc.species
    case species
    #when :goblin # the NEW system
      #npc.setup_behaviours
    when :orc, :skeleton, :wraith, :minotaur, :goblin
      npc.behaviours << Behaviour.new(:fight, npc)
      # npc.behaviours << Behaviour.new(:attack, npc)
      npc.behaviours << Behaviour.new(:flee, npc)
    when :grid_bug
      npc.behaviours << Behaviour.new(:wander, npc)
      # npc.behaviours << Behaviour.new(:escape, npc)
      # npc.behaviours << Behaviour.new(:forage, npc)
    when :rat, :newt
      npc.behaviours << Behaviour.new(:wander, npc)
      # npc.behaviours << Behaviour.new(:forage, npc)
      # npc.behaviours << Behaviour.new(:pack, npc)
    when :leprechaun
      npc.behaviours << Behaviour.new(:steal, npc)
      npc.behaviours << Behaviour.new(:flee, npc)
      npc.behaviours << Behaviour.new(:teleport, npc)
      npc.behaviours << Behaviour.new(:wander, npc)
    else 
      npc.behaviours << Behaviour.new(:wander, npc)
    end
  end

  def self.trauma_threshold_for_fleeing(npc, args)
    case npc.species
    when :goblin
      return 4
    when :orc
      return 5
    when :skeleton
      return 6
    when :wraith
      return 10
    when :minotaur
      return 8
    when :rat, :newt, :grid_bug
      return 1
    else
      return 3
    end
  end

  def self.select_for_npc(npc, args)
    hero = args.state.hero
    # priority one - flee in various ways
    npc.behaviours.shuffle.each do |behaviour|
      if behaviour.kind == :teleport && Trauma.trauma_score(npc, args) > 0 && args.state.rng.d6 > 3
        # if npc is close to hero, try teleporting away
        # check distance to hero
        if Utils.distance_between_entities(npc, hero) < 5 #&& npc.sees?(hero, args)    
          return behaviour
        end
      end
      if behaviour.kind == :flee && Trauma.trauma_score(npc, args) >= self.trauma_threshold_for_fleeing(npc, args)
        return behaviour
      end
    end
    # priority two - fight or threaten
    npc.behaviours.each do |behaviour|
      if behaviour.kind == :fight 
        return behaviour
      end
    end
    # priority three - steal
    npc.behaviours.each do |behaviour|
      if behaviour.kind == :steal 
        if Utils.distance_between_entities(npc, hero) < 10 #&& npc.sees?(hero, args)    
          return behaviour
        end
      end
    end
    # priority four - wander
    npc.behaviours.each do |behaviour|
      if behaviour.kind == :wander 
        return behaviour
      end
    end
    # fallback - random behaviour
    return npc.behaviours.sample
  end

  def execute args
    if args.state.hero.sees?(@npc, args)
      #printf "Executing behaviour #{@kind} for NPC #{@npc.species} at (#{@npc.x}, #{@npc.y}) - level #{@npc.depth} - time #{args.state.kronos.world_time.round(2)}\n"  
    end
    printf "Executing behaviour #{@kind} for NPC #{@npc.species} at (#{@npc.x}, #{@npc.y}) - level #{@npc.depth} - time %.2f\n", args.state.kronos.world_time
    @npc.last_behaviour = @kind
    method_name = @kind.to_s
    if self.respond_to?(method_name)
      self.send(method_name, args)
    end
  end

  def flee args
    # flee from hero (and other enemies)
    npc = @npc
    enemies = npc.enemies
    if enemies.empty?
      # no enemies, wander instead
      wander args
      return
    end
    # find the closest enemy
    closest_enemy = nil
    min_distance = nil
    enemies.each do |enemy|
      if enemy.depth != npc.depth
        next
      end
      dx = enemy.x - npc.x
      dy = enemy.y - npc.y
      distance = Math.sqrt(dx * dx + dy * dy)
      if min_distance.nil? || distance < min_distance
        min_distance = distance
        closest_enemy = enemy
      end
    end
    if closest_enemy.nil?
      # no enemies on this level, wander instead
      wander args
      return
    end
    # set emotions
    npc.feel(:afraid, args)
    # move away from closest enemy
    dx = npc.x - closest_enemy.x
    dy = npc.y - closest_enemy.y
    if dy.abs < dx.abs || closest_enemy.y == npc.y # north-south movement   
      step_x = dx > 0 ? 1 : -1
      step_y = 0
    else
      step_y = dy > 0 ? 1 : -1
      step_x = 0  
    end
    target_x = npc.x + step_x
    target_y = npc.y + step_y
    level = args.state.dungeon.levels[npc.depth]
    target_tile = level.tiles[target_y][target_x]
    if Tile.is_walkable_type?(target_tile, args) && !Tile.occupied?(target_x, target_y, args)
      Tile.enter(npc, target_x, target_y, args)
      return
    else
      # cannot move away, wander instead
      wander args
      return
    end
  end

  def threaten args
    # find target (e.g., hero) and make threatening emote
    npc = @npc
    hero = args.state.hero
    if npc.sees?(hero, args)          
      # make angry emote towards hero if here is not yet enemy!
      HUD.output_message args, "#{npc.name} glares threateningly at you, hurling insults!"
      args.state.kronos.spend_time(npc, npc.walking_speed*0.5, args)
      return
    else
      # cannot see hero, wander instead
      wander args
      return
    end  
  end

  def fight args
    # find target (e.g., hero) and move towards it
    npc = @npc
    if npc.has_status?(:shocked)
      args.state.kronos.spend_time(npc, npc.walking_speed * 4, args)
      return
    end
    hero = args.state.hero
    depth = npc.depth
    if hero && hero.depth == npc.depth
      dx = hero.x - npc.x
      dy = hero.y - npc.y
      distance = Math.sqrt(dx * dx + dy * dy)
      if distance < 20 # aggro range
        if npc.sees?(hero, args)          
          # make angry emote towards hero if here is not yet enemy!
          if !args.state.hero.is_hostile_to?(npc)
            HUD.output_message args, "#{npc.name} stares angrily at you!"
            hero.become_hostile_to(npc)
            npc.feel(:angry, args)
            args.state.kronos.spend_time(npc, npc.walking_speed*0.5, args)
          end
          # move towards hero, but check if the target is walkable first
          if dy.abs < dx.abs || hero.y == npc.y # north-south movement            
            step_x = dx > 0 ? 1 : -1
            step_y = 0
          else
            step_y = dy > 0 ? 1 : -1
            step_x = 0
          end
          npc.apply_new_facing(Utils.direction_from_delta(step_x, step_y)) 
          target_x = npc.x + step_x
          target_y = npc.y + step_y
          #printf "Target x,y: #{target_x}, #{target_y}, hero x,y #{hero.x}, #{hero.y}, npc x,y #{npc.x}, #{npc.y}\n"
          level = args.state.dungeon.levels[depth]
          target_tile = level.tiles[target_y][target_x]
          if !Tile.is_walkable_type?(target_tile, args) && Tile.occupied?(target_x, target_y, args)
            # cannot move towards the hero, try the other direction
            if step_x != 0
              target_x = npc.x
              target_y = npc.y + (dy > 0 ? 1 : -1)
            else
              target_x = npc.x + (dx > 0 ? 1 : -1)
              target_y = npc.y 
            end
          end
          if Tile.is_walkable_type?(target_tile, args) && !Furniture.blocks_movement?(target_x, target_y, level, args)
            if Tile.occupied?(target_x, target_y, args)
              if hero.x == target_x && hero.y == target_y
                # occupied, attack!
                hero.become_hostile_to(npc)
                weapon = npc.equipped_weapon
                Combat.resolve_attack(npc, hero, weapon, args)
                args.state.kronos.spend_time(npc, npc.walking_speed, args)
                return
              else
                # occupied by something else, idle
                args.state.kronos.spend_time(npc, npc.walking_speed, args)
                return
              end
            else
              Tile.enter(npc, target_x, target_y, args)
              SoundFX.play_sound_xy(:footsteps, target_x, target_y, args)
              return
            end
          else
            # cannot move towards hero, idle
            printf "NPC #{@npc.species} cannot move towards hero, idling.\n"
            args.state.kronos.spend_time(npc, npc.walking_speed, args)
            return
          end
        end
      end
    end
    # sensible default - wander
    wander args
  end

  def wander args
    if @npc.has_status?(:shocked)
      args.state.kronos.spend_time(@npc, @npc.walking_speed * 4, args)
      return
    end
    #printf "NPC #{@npc.species} is wandering.\n"
    npc = @npc
    # choose a random location on the map to walk to, stored in @destination
    if npc.x == @destination&.first && npc.y == @destination&.last
      @destination = nil
    end
    if !@destination || args.state.rng.d20 == 1
      target_x = npc.x + args.state.rng.rand(10) - 5
      target_y = npc.y + args.state.rng.rand(10) - 5
      @destination = [target_x, target_y]
    end
    target_coordinates = nil
    case Numeric.rand(3).to_i
    when 1
      # move northsouth
      #print "NPC #{@npc.species} at (#{npc.x}, #{npc.y}) moving towards #{@destination}\n"
      delta = @destination.last > npc.y ? 1 : -1
      target_coordinates = [npc.x, npc.y + delta]
      if delta > 0 && npc.facing != :north
        npc.apply_new_facing(:north)
      elsif delta < 0 && npc.facing != :south
        npc.apply_new_facing(:south)
      end
    when 2
      # move eastwest
      #print "NPC #{@npc.species} at (#{npc.x}, #{npc.y}) moving towards #{@destination}\n"
      delta = @destination.first > npc.x ? 1 : -1
      target_coordinates = [npc.x + delta, npc.y]
      if delta > 0 && npc.facing != :east
        npc.apply_new_facing(:east)
      elsif delta < 0 && npc.facing != :west
        npc.apply_new_facing(:west)
      end
    else
      #printf "NPC #{@npc.species} at (#{npc.x}, #{npc.y}) idling.\n"
      # do nothing
    end
    if target_coordinates
      level = args.state.dungeon.levels[npc.depth]
      if level.trapped_at?(target_coordinates[0], target_coordinates[1], args)
        # do not walk into traps
        args.state.kronos.spend_time(npc, npc.walking_speed, args)
        return
      end
      # do not walk into furniture obstacles
      if Furniture.blocks_movement?(target_coordinates[0], target_coordinates[1], level, args)
        args.state.kronos.spend_time(npc, npc.walking_speed, args)
        return
      end
      # do not walk into boulders
      furniture = Furniture.furniture_at(target_coordinates[0], target_coordinates[1], level, args)
      if furniture && furniture.kind == :boulder
        args.state.kronos.spend_time(npc, npc.walking_speed, args)
        return
      end
      target_tile = level.tiles[target_coordinates[1]][target_coordinates[0]]
      if Tile.is_walkable_type?(target_tile, args) && !Tile.occupied?(target_coordinates[0], target_coordinates[1], args)
        Tile.enter(npc, target_coordinates[0], target_coordinates[1], args)
        SoundFX.play_walking_sound(npc, args)
        return # important to not spend time twice!
      end
    end
    args.state.kronos.spend_time(npc, npc.walking_speed, args) # todo fix speed depending on action
  end

  def steal args
    printf "NPC #{@npc.species} is attempting to steal.\n"
    npc = @npc
    target = args.state.hero
    if npc.sees?(target, args)    
      # if we are next to hero, make a stealing roll
      unless npc.adjacent_to?(target)
        approach(target.x, target.y, args)
        return
      end
      # face hero
      npc.apply_new_facing(Utils.direction_from_to(npc.x, npc.y, target.x, target.y))
      # attempt to steal an item from hero
      steal_roll = args.state.rng.d20 
      steal_roll -= target.anti_steal_ability
      if steal_roll < 5
        # failed & caught stealing!
        target.become_hostile_to(npc)
        npc.become_hostile_to(target)
        HUD.output_message args, "#{npc.name} tries to steal from you but fails!"
        args.state.kronos.spend_time(npc, npc.walking_speed, args)
        return
      end
      if steal_roll < 10
        # failed & almost caught!
        args.state.kronos.spend_time(npc, npc.walking_speed, args)
        return
      end
      # any roll 10+ equals success in stealing
      potential_targets = target.carried_items
      potential_targets = potential_targets.select { |item| !target.is_wearing?(item) }
      potential_targets = potential_targets.select { |item| !target.is_wielding?(item) }  
      unless potential_targets.empty?
        stolen_item = potential_targets.sample
        target.carried_items.delete(stolen_item)
        npc.carried_items << stolen_item
      end
      if steal_roll < 15
        # success but caught!
        target.become_hostile_to(npc)
        npc.become_hostile_to(target)
        if potential_targets.empty?
          HUD.output_message args, "#{npc.name} tries to steal from you but you have nothing!"
        else
          HUD.output_message args, "#{npc.name} steals your #{stolen_item.title(args)}!"
        end
      end
      # steal roll 15+ equals full success, not caught
      args.state.kronos.spend_time(npc, npc.walking_speed, args)
      return
    end
  end

  # action that simply tries to move the NPC closer to given coordinates
  def approach(x, y, args)
    npc = @npc
    dx = x - npc.x
    dy = y - npc.y
    if dy.abs < dx.abs || y == npc.y # north-south movement   
      step_x = dx > 0 ? 1 : -1
      step_y = 0
    else
      step_y = dy > 0 ? 1 : -1
      step_x = 0  
    end
    target_x = npc.x + step_x
    target_y = npc.y + step_y
    npc.apply_new_facing(Utils.direction_from_delta(step_x, step_y)) 
    level = args.state.dungeon.levels[npc.depth]
    target_tile = level.tiles[target_y][target_x]
    if Tile.is_walkable_type?(target_tile, args) && !Tile.occupied?(target_x, target_y, args)
      Tile.enter(npc, target_x, target_y, args)
      return true
    else
      return false
    end
  end

  def teleport args
    hero = args.state.hero
    npc = @npc
    npc.teleport args
    if args.state.hero.sees?(npc, args)
      HUD.output_message args, "#{npc.name} teleports away!"
    end
    args.state.kronos.spend_time(npc, npc.walking_speed, args)
  end
 
end