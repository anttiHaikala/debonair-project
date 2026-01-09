# trying to make custom NPC with some funny internal logic
# after making some more of these, consider making a generic system for behaviour patterns
# that can be composed together to save code duplication
# 
# these are the behaviours we want for grid bugs:
# 
# - do the zig-zag dance with another grid bug (or other grid bugs) to distribute energy evenly
# - select a random room and go there. grid bug can compress to 2D sheet and pass through secret doors and closed doors.
# - poop pearls
# - suck energy from nearby NPCs (also the hero) by adding exhaustion (some nice sound here)
#   "grid bug vibrates and emits a low humming sound as it drains your energy!"
# - light value of grid bug is dependent on its energy level

class GridBug < NPC

  def initialize(x, y, depth)
    super(:grid_bug, x, y, depth)
    @energy_level = 0.5 # range 0.0 to 1.0
  end

  def setup_behaviours
    @behaviours << ReachRoom.new(self, nil) # target room to be set when selected
    @behaviours << ZigZag.new(self)
  end

  # todo: when should this be called??? npc can't just switch behaviours randomly every turn
  # perhaps have some internal state machine or timers to control behaviour switching
  def choose_behaviour
    
  end
  
end

class ReachRoom < Behaviour
  def initialize(npc, target_room)
    super(:reach_room, npc)
    @target_room = target_room
  end

  def execute(args)
    level = Utils.level_by_depth(@npc.depth, args)
    unless @target_room
      # select a random room on the level
      rooms = level.rooms
      @target_room = rooms.sample
    end
    # move towards the target room
    target_x, target_y = @target_room.center
    # find a path to the target room
    #path = Utils.dijkstra(@npc, @npc.x, @npc.y, target_x, target_y, level, args)
    # pop first step from path and move there
    #path.pop
    #next_step = path.pop
    #@npc.x = next_step[0]
    #@npc.y = next_step[1]

    
    args.state.kronos.spend_time(@npc, @npc.walking_speed, args)
    
  end
end
# zig-zag goes east-north-east-north
# zag-zig goes south-west-south-west
# they like to do this dance when they meet another grid bug
# grid bugs go to adjacent squares to start the dance
# they check that they have space to do the dance
# once one of them starts the dance, the other is likely to join in
# once one of them stops the dance, the other is likely to stop as well
# works also for groups
class ZigZag < Behaviour
  def initialize(npc)
    super(:zig_zag, npc)
  end

  def execute(args)
    # move in zig-zag pattern
    # placeholder logic
    if args.state.rng.d2 == 1
      #@npc.move(:up, args)
    else
      #@npc.move(:down, args)
    end
    #ehav@npc.move(:right, args)
    args.state.kronos.spend_time(@npc, @npc.walking_speed, args)
  end
end