class Architect
  # singleton class that creates the dungeon and populates it with entities
  def self.instance
    @instance ||= Architect.new
  end

  def setup(settings)
    @settings ||= {}
    @settings[:levels] ||= 10
    @settings[:level_width] ||= 36  
    @settings[:level_height] ||= 24

  end

  def self.create_seed(args)
    dictionary_adjectives = ['Brave', 'Cunning', 'Wise', 'Fierce', 'Nimble', 'Sturdy', 'Gentle', 'Bold']
    dictionary_subjectives = ['Battle', 'Shadow', 'Light', 'Storm', 'Flame', 'Frost', 'Stone', 'Wind']
    dictionary_prepositions = ['of the', 'from the', 'under the', 'above the', 'beyond the', 'within the', 'across the', 'through the']
    dictionary_location_adjectives = ['Dark', 'Silent', 'Ancient', 'Mystic', 'Hidden', 'Forgotten', 'Enchanted', 'Sacred']
    dictionary_locations = ['Forest', 'Mountain', 'River', 'Desert', 'Cave', 'Swamp', 'Plains', 'Valley']
    seed = ''
    seed += dictionary_adjectives.sample + ' '
    seed += dictionary_subjectives.sample + ' '
    seed += dictionary_prepositions.sample + ' '
    seed += dictionary_location_adjectives.sample + ' '
    seed += dictionary_locations.sample
    args.state.seed = seed.downcase.gsub(' ','_')
    printf "Generated seed: %s\n" % args.state.seed
    return args.state.seed
  end

  def self.set_seed(args, seed)
    printf "Setting seed to: %s\n" % seed
    args.state.seed = seed
  end

  def self.use_seed(args)
    printf "Using seed: %s\n" % args.state.seed
    hash = args.state.seed.hash
    printf "Seed hash: %d\n" % hash
    args.state.rng = SeededRandom.new(hash)
    Math.srand(hash)
  end

  def architect_dungeon(args)
    Leaves.create_kinds(args)
    create_dungeon(args)
    populate_entities(args)
  end

  def create_level(args, depth, vibe)
    level = Level.new
    level.depth = depth
    level.vibe = vibe
    level.tiles = Array.new(@settings[:level_height]) { Array.new(@settings[:level_width], :floor) }
    return level
  end

  def create_dungeon(args)
    # Code to create the dungeon layout
    dungeon = Dungeon.new
    staircase_x = rand(@settings[:level_width])
    staircase_y = rand(@settings[:level_height])
    args.state.dungeon_entrance_x = staircase_x
    args.state.dungeon_entrance_y = staircase_y

    for i in 0..(@settings[:levels] - 1)
      dungeon.levels[i] = create_level(args, i, :hack)
      dungeon.levels[i].create_rooms(args)
      dungeon.levels[i].create_corridors(args)

      # add staircase up (entrance)
      dungeon.levels[i].tiles[staircase_y][staircase_x] = :staircase_up


      # add staircase down
      # sanity check to avoid overlapping staircases and staircases inside walls
      while dungeon.levels[i].tiles[staircase_y][staircase_x] != :floor do
        staircase_x = rand(@settings[:level_width])
        staircase_y = rand(@settings[:level_height])
      end
      dungeon.levels[i].tiles[staircase_y][staircase_x] = :staircase_down if i < (@settings[:levels] - 1) 
    end
    args.state[:dungeon] = dungeon
  end

  def populate_entities(args)
    # Code to add entities to the dungeon
    args.state.entities = []
    dungeon = args.state.dungeon
    hero = Hero.new(args.state.dungeon_entrance_x, args.state.dungeon_entrance_y)
    hero.level = 0
    args.state.hero = hero
    args.state.entities << hero
  end
end