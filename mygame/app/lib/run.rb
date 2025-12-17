# i am not sure if this class is required. but we might have some more
# run-related data later on that doesn't really belong to hero or dungeon
# edit: now we already have it - the item masks
class Run
  attr_accessor :dungeon, :hero
  attr_accessor :potion_masks

  def initialize args
    @potion_masks = Potion.setup_masks(args)
  end

  def setup args, hero
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

    # hero settings
    hero.x = args.state.dungeon_entrance_x
    hero.y = args.state.dungeon_entrance_y
    hero.set_depth(0, args)
    args.state.hero = hero
    args.state.dungeon.levels[0].entities << hero

    @hero = hero
    args.state.current_depth = 0
    args.state.kronos = Kronos.new
    Item.setup_items_for_new_hero(@hero, args)
  end

  def self.start_new_game args, hero
    printf "Starting new game...\n"
    args.state.run = Run.new args
    args.state.run.setup args, hero
    GUI.initialize_state args
    Tile.reset_memory_and_visibility
    printf "Game start complete.\n"
    printf "Dungeon has %d levels.\n" % args.state.dungeon.levels.size
    args.state.dungeon.levels.each_with_index do |level, index|
      printf " %s level %d has %d rooms and %d entities and %d items.\n" % [level.vibe, index, level.rooms.size, level.entities.size, level.items.size]
    end
    args.state.scene = :gameplay
    Lighting.mark_lighting_stale
    Lighting.calculate_lighting(Utils.level(args), args)
    SoundFX.play_sound(:staircase, args)
    Tile.observe_tiles(args)
    HUD.output_message args, "You enter the dungeon seeking the legendary Amulet of Skandor. Good luck!"
end

end