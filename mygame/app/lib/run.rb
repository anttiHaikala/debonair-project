# i am not sure if this class is required. but we might have some more
# run-related data later on that doesn't really belong to hero or dungeon
class Run
  attr_accessor :dungeon, :hero  

  def initialize(args)
  end

  def setup args
    printf "Setting up new run...\n"
    args.state.architect = Architect.new
    Architect.create_seed(args)
    if $fixed_seed
      seed = $fixed_seed
      Architect.set_seed(args, seed) # for testing purposes
    end
    Architect.apply_seed(args)
    printf "Dungeon seed: %s\n" % args.state.seed
    args.state.architect.architect_dungeon(args)
    @dungeon = args.state.dungeon # TODO: should we only access these things below the :run attribute?
    @hero = args.state.hero
    args.state.current_depth = 0
    args.state.kronos = Kronos.new
  end
    
end