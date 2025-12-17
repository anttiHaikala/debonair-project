class Architect
  #  class that creates the dungeon and populates it with entities
  
  def initialize
    @settings = {}
    @settings[:levels] ||= 10
    @settings[:level_width] ||= 58   
    @settings[:level_height] ||= 34
  end

  def self.create_seed(args)
    srand
    dictionary_adjectives = ['Brave', 'Cunning', 'Wise', 'Fierce', 'Nimble', 'Sturdy', 'Gentle', 'Bold']
    dictionary_subjectives = ['Battle', 'Shadow', 'Light', 'Storm', 'Flame', 'Frost', 'Stone', 'Wind', 'Wave', 'Leaf', 'Moon', 'Star', 'Sun', 'Villain', 'Hero', 'Dragon', 'Phoenix', 'Tiger', 'Wolf', 'Eagle', 'Progeny', 'Guardian', 'Seeker']
    dictionary_prepositions = ['of the', 'from the', 'under the', 'above the', 'beyond the', 'within the', 'across the', 'through the', 'near the']
    dictionary_location_adjectives = ['Dark', 'Silent', 'Ancient', 'Mystic', 'Hidden', 'Forgotten', 'Enchanted', 'Sacred', 'Forgotten', 'Lost', 'Cursed', 'Blessed', 'Haunted']
    dictionary_locations = ['Forest', 'Mountain', 'River', 'Desert', 'Cave', 'Swamp', 'Plains', 'Valley', 'Ruins', 'Temple', 'Citadel', 'Grove', 'Isle']
    seed = ''
    seed += dictionary_adjectives.sample + ' '
    seed += dictionary_subjectives.sample + ' '
    seed += dictionary_prepositions.sample + ' '
    seed += dictionary_location_adjectives.sample + ' '
    seed += dictionary_locations.sample
    final_seed = seed.downcase.gsub(' ','_')
    printf "Generated seed: %s\n" % final_seed
    return final_seed
  end

  def self.set_seed(seed, args)
    printf "Setting seed to: %s\n" % seed
    args.state.seed = seed
  end

  def self.apply_seed(args)
    printf "Applying seed: %s\n" % args.state.seed
    hash = args.state.seed.hash
    printf "Seed hash: %d\n" % hash
    args.state.rng = SeededRandom.new(hash)
    Math.srand(hash)
  end

  def architect_dungeon(args)
    Leaves.create_kinds(args)
    create_dungeon(args)
    populate_entities(args)
    populate_items(args)
    Lighting.populate_lights(args)
  end

  def create_level(args, depth, vibe)
    level = Level.new(depth, vibe)
    printf "Creating level %d with vibe %s\n" % [depth, vibe.to_s]
    level.tiles = Array.new(@settings[:level_height]) { Array.new(@settings[:level_width], :floor) }
    return level
  end
  
  def randomize_vibe_for_depth(depth)
    case depth
    when 0,1
      return :hack
    when 7..9
      return [:hack, :water, :rocky].sample
    when 10
      return :fiery
    else
      return [:hack, :lush, :rocky].sample
    end
  end

  def create_dungeon(args)
    # Code to create the dungeon layout
    dungeon = Dungeon.new
    staircase_x = rand(@settings[:level_width]-2) + 1
    staircase_y = rand(@settings[:level_height]-2) + 1
    args.state.dungeon_entrance_x = staircase_x
    args.state.dungeon_entrance_y = staircase_y
    args.state.dungeon = dungeon

    for depth in 0..(@settings[:levels] - 1)

      vibe = randomize_vibe_for_depth(depth)
      level = create_level(args, depth, vibe)

      dungeon.levels[depth] = level

      # add staircase up (entrance)
      previous_tile = level.tiles[staircase_y][staircase_x]
      level.tiles[staircase_y][staircase_x] = :staircase_up
      should_be_same = args.state.dungeon.levels[depth].tiles[staircase_y][staircase_x]

      # add rooms and corridors
      level.create_rooms(staircase_x, staircase_y, args)
      level.create_corridors(args)
      level.add_waters(args)

      # dig corridor from staircase up to entry room
      printf level.rooms.size.to_s + " rooms created at depth %d with vibe %s\n" % [depth, vibe.to_s]
      # find the closest room among level.rooms
      entry_room = level.rooms.min_by { |room| Math.sqrt((room.center_x - staircase_x)**2 + (room.center_y - staircase_y)**2) }
    
      # finally place staircase down in a room
      if depth < (@settings[:levels] - 1)
        exit_room = level.rooms.sample
        staircase_x = Numeric.rand(exit_room.x+1...(exit_room.x + exit_room.w)-1).to_i
        staircase_y = Numeric.rand(exit_room.y+1...(exit_room.y + exit_room.h)-1).to_i        
        safety = 0
        while level.tiles[staircase_y][staircase_x] != :floor do
          safety += 1
          if safety > 50
            printf "Could not place staircase down after 50 tries, placing in center of exit room\n"
            staircase_x = exit_room.x + (exit_room.w / 2).to_i
            staircase_y = exit_room.y + (exit_room.h / 2).to_i
            break
          end
          staircase_x = Numeric.rand(exit_room.x+1...(exit_room.x + exit_room.w)-1).to_i
          staircase_y = Numeric.rand(exit_room.y+1...(exit_room.y + exit_room.h)-1).to_i        
        end
        level.tiles[staircase_y][staircase_x] = :staircase_down
      else
        # last level has no staircase down
        # it has the amulet!!!
        amulet_room = level.rooms.sample
        amulet_x = Numeric.rand(amulet_room.x+1...(amulet_room.x + amulet_room.w)-1).to_i
        amulet_y = Numeric.rand(amulet_room.y+1...(amulet_room.y + amulet_room.h)-1).to_i
        level.tiles[amulet_y][amulet_x] = :floor
        amulet_item = Item.new(:amulet_of_skandor, :amulet)
        amulet_item.depth = depth
        amulet_item.x = amulet_x
        amulet_item.y = amulet_y
        level.items << amulet_item
      end

      level.add_foliage(args)
      Trap.populate_for_level(level, args)

    end
    args.state.dungeon = dungeon
  end

  def populate_entities(args)
    NPC.populate_dungeon(args.state.dungeon, args)
  end

  def populate_items(args)
    Item.populate_dungeon(args.state.dungeon, args)
  end

  def setup_endgame(args)
    for level in args.state.dungeon.levels
      NPC.populate_with_endgame_challenges(level, args)        
    end
  end
end