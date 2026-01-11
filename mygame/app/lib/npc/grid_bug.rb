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
# - heal any other entity if their energy level is high and the other entity has wounds
# 
# note on behaviour system:
# - behaviours have start, execution and finish methods
# - if npc has no behaviour, it will choose and start one
# - if npc has a behaviour, it will keep on executing it
# - if behaviour is finished, it will clean up and remove itself from npc
# - outside code can also finish behaviour, for example if the npc is wounded and needs to flee
# - TODO decision: do we even need the behaviour list??? 
# - TODO what about simultaneous side quest behaviours? like snarl at hero while doing main behaviour?
# - maybe each entity could have multiple quests going on at same time, with priorities and opportunity costs?
#   if the npc opportunity cost of a behaviour is low, npc can switch to it while doing something else
#   for example, if a grid bug is going to a room, but sees a wounded npc on the way, it can stop and heal it
#   or if it sees another grid bug, it can stop and do the zig-zag dance for a while
#   opportunity cost could be calculated based on distance to target, energy level, urgency of behaviour etc.
#   this would make npc behaviour more dynamic and responsive to the environment


class GridBug < NPC

  attr_accessor :behaviour, :social_battery, :energy_level, :name

  def initialize(x, y, depth)
    super(:grid_bug, x, y, depth)
    @energy_level = 0.5 # range 0.0 to 1.0
    @social_battery = 0.5 # range 0.0 to 1.0
    @path = nil
    @name = ["John", "Ziggy", "Bugsy", "Glimmer", "Spark", "Peter", 'Julie', 'Sarah'].sample 
  end

  # THIS ONE MIGHT GET DEPCRECATED 
  def setup_behaviours
    @behaviours << ReachRoom.new(self) # target room to be set when selected
    @behaviours << ZigZag.new(self)
  end

  # key method! TODO: move to Entity
  def take_action args
    printf "GridBug %s at (%d,%d) taking action at timestamp %.2f\n", @name, @x, @y, args.state.kronos.world_time
    # if no current behaviour, choose one
    if @behaviour.nil?
      self.choose_behaviour args
    end
    # execute current behaviour
    if @behaviour
      @behaviour.execute args
    end
  end
  
  # TODO: move to Entity
  def set_current_behaviour behaviour, args
    printf "GridBug %s at (%d,%d) switching to behaviour %s\n", @name, @x, @y, behaviour && behaviour.title
    # end current behaviour if any
    if @behaviour
      @behaviour.finish args
    end 
    @behaviour = behaviour
    @behaviour.start args if @behaviour
  end

  # KEY METHOD! this belongs here, as every npc chooses it's behaviour differently
  def choose_behaviour args
    level = Utils.level_by_depth(@depth, args)
    # if close to another grid bug, do zig-zag dance
    nearby_bugs = Utils.entities_within_radius(@x, @y, 3, level).select { |e| e.is_a?(GridBug) && e != self }
    if nearby_bugs.any?
      if self.social_battery > 0.4
        set_current_behaviour(ZigZag.new(self), args)
        return
      end
    end
    # otherwise, go to a random room
    set_current_behaviour(ReachRoom.new(self), args)
  end
  
end

class Chill < Behaviour
  def initialize npc
    super(:chill, npc)
    @chill_amount = 0
    @chill_max = 5
  end

  def start args
    # do nothing special on start
  end

  def finish args
    # do nothing special on finish
  end

  def execute(args)
    if @chill_amount >= @chill_max
      # finished chilling
      args.state.kronos.spend_time(@npc, @npc.walking_speed, args)
      @npc.set_current_behaviour(nil, args)
    else 
    # do nothing for a while
      @npc.social_battery += 0.03
      if @npc.social_battery > 1.0
        @npc.social_battery = 1.0
      end
      args.state.kronos.spend_time(@npc, @npc.walking_speed, args)
      @chill_amount += 1
    end
  end
end

class ReachRoom < Behaviour
  def initialize npc
    super(:reach_room, npc)
  end

  def title
    if @target_room
      room_name = @target_room.name
    else 
      room_name = "unknown"
    end
    "Reach Room #{room_name}"
  end

  def start args
    level = Utils.level_by_depth(@npc.depth, args)
    # select a random room on the level
    rooms = level.rooms
    @target_room = rooms.sample
    printf "GridBug %s at (%d,%d) starting ReachRoom behaviour to room %s at (%d,%d)\n", @npc.name, @npc.x, @npc.y, @target_room.name, @target_room.center[0], @target_room.center[1]
    # set destination to center of the room
    target_x, target_y = @target_room.center
    @destination = [target_x, target_y, @npc.depth]
    @path = Utils.dijkstra(@npc, @npc.x, @npc.y, target_x, target_y, level, args)
  end

  def finish args
    printf "GridBug %s at (%d,%d) finishing ReachRoom behaviour\n", @npc.name, @npc.x, @npc.y
    @target_room = nil
    @path = nil
  end

  def execute(args)
    level = Utils.level_by_depth(@npc.depth, args)
    # move towards the target room
    if @target_room.nil?
      # no target room, finish behaviour
      self.finish args
      args.state.kronos.spend_time(@npc, @npc.walking_speed, args)
      return
    end
    target_x, target_y = @target_room.center
    if @npc.x == target_x && @npc.y == target_y
      self.finish args
      args.state.kronos.spend_time(@npc, @npc.walking_speed, args)
      return
    end
    if @path.nil? || @path.empty?
      @path = Utils.dijkstra(@npc, @npc.x, @npc.y, target_x, target_y, level, args)
    end
    if @path.nil? || @path.empty?
      # no path found, finish behaviour
      self.finish args
      args.state.kronos.spend_time(@npc, @npc.walking_speed, args)
      return
    end
    # pop first step from path and move there
    next_step = @path.shift
    if next_step.nil?
      # no more steps, finish behaviour
      self.finish args
      return
    end
    printf "NEXT STEP: "
    printf next_step.inspect + "\n"
    dx = next_step[:x] - @npc.x
    dy = next_step[:y] - @npc.y
    printf "DX: %d, DY: %d\n", dx, dy    
    if dx.abs > dy.abs
      if dx > 0
        @npc.move(:east, args)
      else
        @npc.move(:west, args)
      end
    else
      if dy < 0 
        @npc.move(:south, args)
      else
        @npc.move(:north, args)
      end
    end
    # recharge social battery
    nearby_bugs = Utils.entities_within_radius(@npc.x, @npc.y, 3, level).select { |e| e.is_a?(GridBug) && e != @npc }
    if !nearby_bugs.any?
      @npc.social_battery += 0.01
      if @npc.social_battery > 1.0
        @npc.social_battery = 1.0
      end
    end
    # spend time - important!!!
    args.state.kronos.spend_time(@npc, @npc.walking_speed, args)
    # if reached target room, finish behaviour
    if @npc.x == target_x && @npc.y == target_y
      @npc.set_current_behaviour(Chill.new(@npc), args)
    end
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
    @steps = [:east, :north, :east, :north, :west, :south, :west, :south]
    @current_step = 0
    @repetitions = 0
  end

  def title
    "ZigZag Dance"
  end

  def execute(args)
    if @npc.social_battery < 0.2
      # too tired to dance
      args.state.kronos.spend_time(@npc, @npc.walking_speed, args)
      @npc.set_current_behaviour(nil, args)
      return
    end
    if @repetitions >= 3
      # finished dancing
      args.state.kronos.spend_time(@npc, @npc.walking_speed, args)
      @npc.set_current_behaviour(nil, args)
      return
    end
    # perform next step
    direction = @steps[@current_step]
    @npc.move(direction, args)
    @current_step += 1
    if @current_step >= @steps.length
      @current_step = 0
      @repetitions += 1
      @npc.social_battery -= 0.03
    end
    # spend time for the step
    args.state.kronos.spend_time(@npc, @npc.walking_speed, args)
  end
end