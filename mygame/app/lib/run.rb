# i am not sure if this class is required. but we might have some more
# run-related data later on that doesn't really belong to hero or dungeon
# edit: now we already have it - the item masks
class Run
  attr_accessor :dungeon, :hero
  attr_accessor :potion_masks

  def initialize(args)
    @potion_masks = Potion.setup_masks(args)
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
    args.state.current_depth = 0
    args.state.kronos = Kronos.new
    Item.setup_items_for_new_hero(@hero, args)
  end
    
end