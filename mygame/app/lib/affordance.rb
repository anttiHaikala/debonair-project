# these are actions that can be performed on tiles or objects, available through cursor interaction
# 
# this is a very key class, any new interactions are generally added here first
# 
# this game offers a VERY wide variety of actions that can be performed, so this class
# is very central to the gameplay experience
# 
# TODO: should we start subclassing all this stuff? Like ShootAffordance, OpenDoorAffordance, etc?
# that might make the code cleaner, or messier, depending on who you ask.
class Affordance
  attr_reader :level, :x, :y, :kind, :target_entity, :item

  def initialize(level, x, y, kind, target_entity = nil, item = nil)
    @level = level
    @x = x
    @y = y
    @kind = kind
    @target_entity = target_entity  
    @item = item
  end

  def title(args)
    case @kind
    when :do_nothing
      return "Do nothing"
    when :shoot
      return "Shoot #{@target_entity.title(args)} with #{@item.title(args)}"
    when :throw
      return "Throw #{@item.title(args)} at #{@target_entity.title(args)}"
    when :zap
      return "Zap with #{@item.title(args)}"
    when :disarm_trap
      return "Disarm trap"
    when :open_door
      return "Open door"
    when :close_door
      return "Close door"
    when :break_door
      return "Break door"
    when :climb_up
      return "Climb up staircase"
    when :climb_down
      return "Climb down staircase"
    when :push_boulder
      return "Push boulder"
    when :squeeze_through
      return "Squeeze through"
    else
      return "Unknown affordance"
    end
  end

  def self.populate_for_tile(hero, x, y, level, args)
    affordances = []

    # affordances given by magic wands
    # affordances given by spells
    # affordances given by ranged weapons
    # affordances given by throwing potions
    target_entity = level.entity_at(x, y)
    hero.wielded_items.each do |item|
      next unless item
      if item.category == :wand
        affordances << Affordance.new(level, x, y, :zap, target_entity, item)
      end
      if item.is_ranged?
        if target_entity && target_entity != hero
          affordances << Affordance.new(level, x, y, :shoot, target_entity, item)
        end
      end
      if item.is_throwable?
        if target_entity && target_entity != hero
          affordances << Affordance.new(level, x, y, :throw, target_entity, item)
        end
      end
    end
    # opening and closing doors
    furniture = Furniture.furniture_at(x, y, level, args)
    if furniture && furniture.kind == :door
      if furniture.openness == 0
        affordances << Affordance.new(level, x, y, :open_door, nil, nil)
        affordances << Affordance.new(level, x, y, :break_door, nil, nil)
      else
        affordances << Affordance.new(level, x, y, :close_door, nil, nil)
        affordances << Affordance.new(level, x, y, :break_door, nil, nil)
      end
    end
    if furniture && furniture.kind == :secret_door && furniture.seen_by_hero
      if furniture.openness == 0
        affordances << Affordance.new(level, x, y, :open_door, nil, nil)
        affordances << Affordance.new(level, x, y, :break_door, nil, nil)
      else
        affordances << Affordance.new(level, x, y, :close_door, nil, nil)
        affordances << Affordance.new(level, x, y, :break_door, nil, nil)
      end
    end 
    # boulders
    if furniture && furniture.kind == :boulder
      affordances << Affordance.new(level, x, y, :push_boulder, nil, nil)
    end

    # squeeze through a tight spot
    if level.tight_spot_between?(hero.x, hero.y, x, y, args)
      affordances << Affordance.new(level, x, y, :squeeze_through, nil, nil)
    end

    # tile specific affordances
    tile = level.tiles[y][x]
    if hero.x == x && hero.y == y
      case tile
      when :staircase_up
        affordances << Affordance.new(level, x, y, :climb_up, nil, nil)
      when :staircase_down
        affordances << Affordance.new(level, x, y, :climb_down, nil, nil)
      end
    end

    
    # throwing potions - not impelemented yet
    # hero.carried_items.each do |item|
    #   if item.category == :potion && item.kind
    #     if target_entity && target_entity != hero
    #       affordances << Affordance.new(level, x, y, :throw, target_entity, item)
    #     end
    #   end
    # end
    
    # disarming traps - not implemented yet
    level.traps.each do |trap|
      if trap.x == x && trap.y == y && trap.found
        affordances << Affordance.new(level, x, y, :disarm_trap, nil, nil)
      end
    end
    
    affordances << Affordance.new(level, x, y, :do_nothing, nil, nil)
    return affordances
  end

  def execute(hero, args)
    case @kind
    when :do_nothing
      return
    when :climb_up
      GUI.take_staircase_up args
    when :climb_down
      GUI.take_staircase_down args
    when :open_door
      furniture = Furniture.furniture_at(@x, @y, @level, args)
      if furniture && (furniture.kind == :door || furniture.kind == :secret_door)
        furniture.is_toggled_by(hero, args )
      end
    when :close_door
      furniture = Furniture.furniture_at(@x, @y, @level, args)
      if furniture && (furniture.kind == :door || furniture.kind == :secret_door)
        furniture.is_toggled_by(hero, args )
      end
    when :break_door
      furniture = Furniture.furniture_at(@x, @y, @level, args)
      if furniture && furniture.breakable
        die_roll = args.state.rng.d20
        bonuses = hero.strength_modifier + (hero.age == :elder ? -2 : 0) + (hero.age == :teenage ? -1 : 0)
        required_roll = furniture.breakable
        damage = die_roll - required_roll
        if damage > 0 
          furniture.breakable -= damage 
          HUD.output_message(args, "#{hero.name} smashes the door, damaging it!")
          if furniture.breakable <= 0
            HUD.output_message(args, "The door breaks apart!")
            level.furniture.delete(furniture)
            if furniture.kind == :secret_door
              # update tile to a floor tile
              level.tiles[@y][@x] = :floor # TODO: maybe choose the style from adjacent tiles? dirt floor is ok too...
            end
            SoundFX.play(:door_break, args) 
          end
        else
          HUD.output_message(args, "#{hero.name} fails to damage the door.")
        end
      end
    when :push_boulder
      printf "Affordance: push boulder at %d,%d\n", @x, @y
      # try to push boulder
      furniture = Furniture.furniture_at(@x, @y, @level, args)
      if furniture && furniture.kind == :boulder
        die_roll = args.state.rng.d6 + args.state.rng.d6 # 2d6
        bonuses = hero.strength_modifier + (hero.age == :elder ? -2 : 0) + (hero.age == :teenage ? -1 : 0)
        required_roll = 9
        total_roll = die_roll + bonuses
        if total_roll >= required_roll
          # push boulder to next tile
          dx = @x - hero.x
          dy = @y - hero.y
          old_x = furniture.x
          old_y = furniture.y
          new_x = furniture.x + dx
          new_y = furniture.y + dy
          pit = false
          tile_blocks_boulder = false
          target_within_bounds = @level.is_within_bounds?(new_x, new_y)
          blocking_furniture = Furniture.furniture_at(new_x, new_y, @level, args)
          target_tile_type = @level.tiles[new_y][new_x]
          if target_tile_type == :wall || target_tile_type == :rock
            tile_blocks_boulder = true
          end
          if blocking_furniture && blocking_furniture.kind == :pit
            pit = blocking_furniture
            blocking_furniture = nil
          end
          blocking_entity = @level.entity_at(new_x, new_y)
          if target_within_bounds && !blocking_furniture && !blocking_entity && !tile_blocks_boulder
            furniture.x = new_x
            furniture.y = new_y
            HUD.output_message(args, "#{hero.name} pushes the boulder!")
            SoundFX.play(:boulder_move, args)
            args.state.kronos.spend_time(hero, hero.walking_speed * 3, args) # pushing is slow
            if pit
              HUD.output_message(args, "The boulder falls into the pit and fills it!")
              SoundFX.play(:boulder_fall, args)
              @level.furniture.delete(furniture)
              @level.furniture.delete(pit)
            end
            Tile.enter(hero, old_x, old_y, args) # movement of the hero onto the previous boulder tile
          else
            HUD.output_message(args, "The boulder is not moving any further.")
          end
        else
          HUD.output_message(args, "#{hero.name} fails to push the boulder.")
        end
      end
    when :squeeze_through
      printf "Affordance: squeeze through at %d,%d\n", @x, @y
      # automatic squeeze through
      args.state.kronos.spend_time(hero, hero.walking_speed * 2, args) # squeezing is slow
      Tile.enter(hero, @x, @y, args)
    when :shoot
      Combat.resolve_ranged_attack(hero, @item, @target_entity, args)
      args.state.kronos.spend_time(hero, hero.walking_speed * 0.7, args) # todo fix speed depending on action
    when :zap
      Wand.zap_with(hero, @item, @x, @y, @target_entity, args)
      args.state.kronos.spend_time(hero, hero.walking_speed * 0.5, args) # todo fix speed depending on action and user intellectual speed
    # when :throw
    #   Hero.throw_item_at(@item, @target_entity, args)
    # when :zap
    #   Hero.zap_with(@item, args)
    when :disarm_trap
      Trap.disarm_trap_at(hero, @x, @y, @level, args)
    else
      printf "Unknown affordance executed.\n"
    end
    
  end
end