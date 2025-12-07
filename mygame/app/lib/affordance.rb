# these are actions that can be performed on tiles or objects
class Affordance
  attr_reader :level, :x, :y, :kind, :target_entity, :item

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
      if item.category == :wand
        affordances << Affordance.new(level, x, y, :zap, target_entity, item)
      end
      if Weapon.is_ranged_weapon?(item)
        if target_entity && target_entity != hero
          affordances << Affordance.new(level, x, y, :shoot, target_entity, item)
        end
      end
      if Weapon.is_throwable_weapon?(item)
        if target_entity && target_entity != hero
          affordances << Affordance.new(level, x, y, :throw, target_entity, item)
        end
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
    # level.traps.each do |trap|
    #   if trap.x == x && trap.y == y && trap.found
    #     affordances << Affordance.new(level, x, y, :disarm_trap, nil, nil)
    #   end
    # end
    affordances << Affordance.new(level, x, y, :do_nothing, nil, nil)
    return affordances
  end

  def initialize(level, x, y, kind, target_entity = nil, item = nil)
    @level = level
    @x = x
    @y = y
    @kind = kind
    @target_entity = target_entity  
    @item = item
  end

  def execute(hero, args)
    case @kind
    when :do_nothing
      return
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
    # when :disarm_trap
    #   Hero.disarm_trap_at(@x, @y, args)
    else
      printf "Unknown affordance executed.\n"
    end
    
  end
end