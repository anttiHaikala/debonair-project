# i am not sure if this class is required. but we might have some more
# run-related data later on that doesn't really belong to hero or dungeon
class Run
  attr_accessor :dungeon, :hero  

  def initialize(args)
  end

  def setup args
    printf "Setting up new run...\n"
    args.state.architect = Architect.new
    seed = Architect.create_seed(args)
    if $fixed_seed
      seed = $fixed_seed
    end
    Architect.set_seed(seed, args)
    Architect.apply_seed(args)
    printf "Dungeon seed: %s\n" % args.state.seed
    args.state.architect.architect_dungeon(args)
    @dungeon = args.state.dungeon # TODO: should we only access these things below the :run attribute?
    @hero = args.state.hero
    @hero.carried_items << Scroll.new(:scroll_of_fireball)
    @hero.carried_items << Scroll.new(:scroll_of_fireball)
    @hero.carried_items << Scroll.new(:scroll_of_fireball)
    @hero.carried_items << Ring.new(:ring_of_warning)
    @hero.carried_items << Potion.new(:potion_of_poison)
    @hero.carried_items << Potion.new(:potion_of_speed)
    @hero.carried_items << Potion.new(:potion_of_strength)
    @hero.carried_items << Potion.new(:potion_of_telepathy)
    args.state.current_depth = 0
    args.state.kronos = Kronos.new
  end
    
end