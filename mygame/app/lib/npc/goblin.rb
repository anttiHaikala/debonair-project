# this class is for goblin NPCs, which have specific behaviours and traits
# these are game-specific content that extends the generic NPC class
# goblin's have three different tribes that share affinity within their tribe
# but are hostile to other tribes
# 
# BLACK CLAW the mighty warriors who also have some deadly yet unreliable magic (black)
# FOOTWORK the sneaky rogues who excel at speed, stealth, guile and ambushes (red)
# SHADOW SHANK are the merchants and traders, good at bartering and negotiation (blue)
# 
# TODO: all tribes, or at least one of them, has a nest in the dungeon

GOBLIN_TRIBES = [:black_claw, :footwork, :shadow_shank]

class Goblin < NPC
  def initialize
    super
    @kind = :goblin
    @description = "A small, green humanoid with sharp teeth."
    @tribe = GOBLIN_TRIBES.sample
    @hostile_tribes = GOBLIN_TRIBES - [@tribe]
  end

  def setup_behaviours
    # all goblins have fight and flee behaviours
    @behaviours << Behaviour.new(:fight, self)
    @behaviours << Behaviour.new(:flee, self)

    # tribe-specific behaviours
    case @tribe
    when :black_claw
      @behaviours << Behaviour.new(:use_magic, self)
    when :footwork
      @behaviours << Behaviour.new(:stealth_attack, self)
    when :shadow_shank
      @behaviours << Behaviour.new(:barter, self) # i got some rare things for sale, stranger
    end
  end

  def select_behaviour
    # survival needs first
    

    # enemy hero in sight?
    # prioritize fight or flee or fawn behaviour
    # neutral hero in sight?    
    # prioritize natural behaviour
    # no hero in sight?
    # wander around level
  end

end