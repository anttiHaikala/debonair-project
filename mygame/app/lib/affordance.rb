# these are actions that can be performed on tiles or objects 
# usually these actions are accessed via the "look mode"
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
      else
        affordances << Affordance.new(level, x, y, :close_door, nil, nil)
      end
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
            SoundFX.play(:door_break, args) 
          end
        else
          HUD.output_message(args, "#{hero.name} fails to damage the door.")
        end
      end
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