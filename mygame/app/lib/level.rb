class Level

  attr_accessor :depth, :tiles, :items, :lights
  attr_accessor :floor_hsl # this determines the color scheme of the level
  attr_accessor :vibe # :hack, :lush, :swamp, :fiery, :ice, :rocky, :water
  attr_accessor :rooms
  attr_accessor :entities
  attr_accessor :lighting
  attr_accessor :los_cache
  attr_accessor :foliage
  attr_accessor :effects
  attr_accessor :fire
  attr_accessor :traps
  attr_accessor :furniture

  def initialize(depth, vibe = :hack)
    @depth = depth
    @tiles = []
    @foliage = []
    @effects = [] # for timed effects on tiles
    @fire = [] # for longer fires
    @vibe = vibe  
    self.set_colors
    @rooms = []
    @entities = []
    @items = []
    @traps = []
    @lights = []
    @furniture = []
    @lighting = nil # lighting value of each tile
    @los_cache = {}
  end

  def reset_los_cache
    @los_cache = {}
  end

  def width
    return @tiles[0].size if @tiles.size > 0
  end

  def height
    return @tiles.size if @tiles
  end

  def set_colors
    case @vibe
    when :hack
      @floor_hsl = [34, 0, 100]
    when :lush
      @floor_hsl = [180, 255, 100]
    when :swamp
      @floor_hsl = [34, 0, 100]
    when :fiery
      @floor_hsl = [0, 255, 100]
    when :ice
      @floor_hsl = [200, 100, 90]
    when :rocky
      @floor_hsl = [40, 0, 80]
    when :water
      @floor_hsl = [200, 150, 80]
    else  
      @floor_hsl = [34, 0, 100]
    end
  end

  def entity_at(x, y)
    @entities.each do |entity|
      if entity.x == x && entity.y == y
        return entity
      end
    end
    return nil
  end

  def tile_at(x, y)
    unless x.is_a?(Integer) && y.is_a?(Integer)
      printf "tile_at called with non-integer coordinates: (%s, %s)\n" % [x.to_s, y.to_s]
      return nil
    end
    return nil unless @tiles
    return nil unless @tiles.size > 0
    return nil if y < 0 || y >= @tiles.size
    return nil if x < 0 || x >= @tiles[0].size
    return @tiles[y][x]
  end

  def create_entry_room(staircase_x, staircase_y, args)
    room_width = 2 + args.state.rng.d6
    room_height = 2 + args.state.rng.d6
    args.state.dungeon_entrance_x
    entry_room_x = staircase_x - (room_width / 2).to_i
    entry_room_x = 1 if entry_room_x < 1
    entry_room_y = staircase_y - (room_height / 2).to_i
    entry_room_y = 1 if entry_room_y < 1
    entry_room = Room.new(entry_room_x, entry_room_y, room_width, room_height)
    @rooms << entry_room
    printf "Created entry room at (%d,%d) size %d x %d\n" % [entry_room.x, entry_room.y, entry_room.w, entry_room.h]
    if self.vibe == :rocky
      # make rocky levels have bigger rooms that are round, not square
      radius_x = (entry_room.w / 2).to_i
      radius_y = (entry_room.h / 2).to_i
      for i in entry_room.y...(entry_room.y + entry_room.h)
        @tiles[i] ||= []
        for j in entry_room.x...(entry_room.x + entry_room.w)
          # check level boundaries
          next if i < 1 || i >= @tiles.size - 1
          next if j < 1 || j >= @tiles[0].size - 1
          dx = j - entry_room.center_x
          dy = i - entry_room.center_y
          if ((dx * dx) * (radius_y * radius_y) + (dy * dy) * (radius_x * radius_x)) <= (radius_x * radius_x) * (radius_y * radius_y)
            # inside ellipse, no walls
            @tiles[i][j] = :floor if @tiles[i][j] == :rock
          end
        end
      end
    else
      for i in entry_room.y...(entry_room.y + entry_room.h)
        @tiles[i] ||= []
        for j in entry_room.x...(entry_room.x + entry_room.w)
          if i == entry_room.y || i == (entry_room.y + entry_room.h - 1) || j == entry_room.x || j == (entry_room.x + entry_room.w - 1)
            @tiles[i][j] = :wall if @tiles[i][j] == :rock
          else
            @tiles[i][j] = :floor if @tiles[i][j] == :rock
          end
        end
      end
    end
  end

  def create_rooms(staircase_x, staircase_y, args)
    # first put some rock in there
    for y in 0...@tiles.size
      for x in 0...@tiles[y].size
        @tiles[y][x] = :rock unless @tiles[y][x] == :staircase_up
      end
    end
    # create entry room
    create_entry_room(staircase_x, staircase_y, args)
    # Code to create rooms in the level
    room_target = Numeric.rand(7..12)
    safety = 0  
    while @rooms.size < room_target do
      safety += 1
      if safety > 500
        printf "Could not create enough rooms after 500 tries, created %d out of %d\n" % [@rooms.size, room_target]
        break
      end
      width = Numeric.rand(5..11) # little nod to the classic rogue and wide displays
      height = Numeric.rand(5..9)
      buffer = 2
      x = rand(@tiles[0].size - width - buffer*2) + buffer
      y = rand(@tiles.size - height - buffer*2) + buffer
      new_room = Room.new(x, y, width, height)
      if self.vibe != :rocky
        if rooms.none? { |room| room.intersects?(new_room) }
          rooms << new_room
        end
      else
        rooms << new_room
      end
    end
    @rooms.each do |room|
      if self.vibe == :rocky
        # make rocky levels have bigger rooms that are round, not square
        room.w += 4
        room.h += 4
        radius_x = (room.w / 2).to_i
        radius_y = (room.h / 2).to_i
        for i in room.y...(room.y + room.h)
          for j in room.x...(room.x + room.w)
            # check level boundaries
            next if i < 1 || i >= @tiles.size - 1
            next if j < 1 || j >= @tiles[0].size - 1
            dx = j - room.center_x
            dy = i - room.center_y
            if ((dx * dx) * (radius_y * radius_y) + (dy * dy) * (radius_x * radius_x)) <= (radius_x * radius_x) * (radius_y * radius_y)
              # inside ellipse, no walls
              @tiles[i][j] = :floor if @tiles[i][j] == :rock
            end
          end
        end
      else
        for i in room.y...(room.y + room.h)
          for j in room.x...(room.x + room.w)
            if i == room.y || i == (room.y + room.h - 1) || j == room.x || j == (room.x + room.w - 1)
              @tiles[i][j] = :wall if @tiles[i][j] == :rock
            else
              @tiles[i][j] = :floor if @tiles[i][j] == :rock
            end
          end
        end
      end
    end
  end
  
  def has_staircase_up?
    @tiles.each do |row|
      row.each do |tile|
        return true if tile == :staircase_up
      end
    end
    return false
  end

  def staircase_down_x
    pos = staircase_down_position
    return pos[:x] unless pos.nil?
    return nil
  end

  def staircase_down_y
    pos = staircase_down_position
    return pos[:y] unless pos.nil?
    return nil
  end

  def staircase_down_position
    for y in 0...@tiles.size
      for x in 0...@tiles[y].size
        if @tiles[y][x] == :staircase_down
          return {:x => x, :y => y}
        end
      end
    end
    return nil
  end

  def is_walkable?(x, y, args)
    tile = tile_at(x, y)
    furniture = Furniture.furniture_at(x, y, self, args)
    return false if furniture && furniture.blocks_movement?(args)
    return false if tile.nil?
    return true if Tile.is_walkable?(tile, args)
    return true if tile == :wall && furniture && furniture.kind == :secret_door && furniture.openness > 0.0
    return false
  end

  def add_foliage(args)
    # add some foliage to the level based on vibe
    foliage_types = []
    case @vibe
    when :hack
      foliage_types = [:small_rocks, :puddle]
    when :lush
      foliage_types = [:lichen, :moss, :fungus, :small_plant, :puddle]
    when :swamp
      foliage_types = [:moss, :fungus, :small_plant]
    when :ice
      foliage_types = [:lichen, :moss, :fungus]
    # water
    # fiery
    else
      foliage_types = [:puddle, :lichen]
    end
    @tiles.each_index do |y|
      @foliage[y] ||= []
      @tiles[y].each_index do |x|
        @foliage[y][x] ||= []
        if args.state.rng.d6 >= 6
          @foliage[y][x] = foliage_types.sample if [:floor, :water].include?(@tiles[y][x])
        end
      end
    end
  end

  def print_minimap_around(x, y, range=1)
    for j in (y - range)..(y + range)
      row = "  "
      for i in (x - range)..(x + range)
          furniture = Furniture.furniture_at(i, j, self, nil)
          if furniture && furniture.kind == :door
            row += "+"
            next
          end
          if furniture && furniture.kind == :secret_door
            row += "="
            next
          end
          tile = tile_at(i, j)
          case tile
          when :floor
            row += "."
          when :rock
            row += "*"
          when :wall
            row += "#"
          when :water
            row += "~"
          when :staircase_up
            row += "<"
          when :staircase_down
            row += ">"
          else
            row += "?"
          end
      end
      printf "%s\n" % row
    end
  end

  def dig_corridor(args, x1, y1, x2, y2)
    printf "Digging corridor from (%d,%d) to (%d,%d) at depth %d \n" % [x1, y1, x2, y2, @depth]
    return if x1 == x2 && y1 == y2 # no need to dig
    current_x = x1
    current_y = y1
    direction = nil
    safety = 0
    while current_x != x2 || current_y != y2 do
      safety += 1
      if safety > 500
        printf "  corridor digging aborted due to safety limit.\n"
        break
      end
      case direction
      when :east
        current_x += 1
      when :west
        current_x -= 1
      when :north
        current_y += 1
      when :south
        current_y -= 1
      end
      if current_y < 0 || current_y >= @tiles.size || current_x < 0 || current_x >= @tiles[0].size
        printf "  digging out of bounds at (%d,%d), aborting corridor.\n" % [current_x, current_y]
        break
      end
      new_tile = nil
      create_door = false
      current_tile = @tiles[current_y][current_x]
      printf "  digging %s at (%d,%d) %s\n" % [direction, current_x, current_y, current_tile]
      self.print_minimap_around(current_x, current_y, 2)
      if current_tile == :rock
        new_tile = :floor
      end
      if current_tile == :wall
        # first make sure there is wall on both sides of this piece of wall
        if direction == :east || direction == :west
          # check if there is door either north or south - doors are not tiles???
          if @tiles[current_y-1][current_x] == :door || @tiles[current_y+1][current_x] == :door
            next # let's just skip to next square. hope the door fixed it
          end
          if @tiles[current_y-1][current_x] == :wall && @tiles[current_y+1][current_x] == :wall
            new_tile = :floor 
            create_door = true
            printf "  .. should create door at (%d,%d)\n" % [current_x, current_y]
          else
            new_tile = :floor 
          end
          if direction == :east && @tiles[current_y][current_x+1] == :wall || direction == :west && @tiles[current_y][current_x-1] == :wall
            printf "  .. running into double wall: step back and sidestep!\n"
            if direction == :east
              current_x -= 1
            else
              current_x += 1
            end
            if @tiles[current_y-1][current_x] == :wall
              direction = :north
            else
              direction = :south
            end
            next
          end
        elsif direction == :north || direction == :south
          if @tiles[current_y][current_x-1] == :door || @tiles[current_y][current_x+1] == :door
            next # let's just skip to next square. hope the door fixed it
          end
          if @tiles[current_y][current_x-1] == :wall && @tiles[current_y][current_x+1] == :wall
            new_tile = :floor
            create_door = true
          else
            new_tile = :floor 
          end
          if direction == :north && @tiles[current_y-1][current_x] == :wall || direction == :south && @tiles[current_y+1][current_x] == :wall
            printf "  .. running into double wall: step back and sidestep!\n"
            if direction == :north
              current_y -= 1
            else
              current_y += 1
            end
            if @tiles[current_y][current_x-1] == :wall
              direction = :east
            else
              direction = :west
            end
            next
          end
        else
          new_tile = :floor
        end
        # check if door already exists here
        if Furniture.furniture_at(current_x, current_y, self, args)
          create_door = false
        end
        if create_door
          printf "  .. creating door at (%d,%d) (current tile: %s direction: %s)\n" % [current_x, current_y, @tiles[current_y][current_x].to_s, direction]
          if args.state.rng.d6 > 1
            door_angle = [:east, :west].include?(direction) ? 90 : 0
            secret_roll = args.state.rng.d20
            if secret_roll > 17
              kind = :secret_door
              new_tile = :wall # keep wall tile for secret door
            else
              kind = :door
            end
            door = Furniture.new(kind, :wood, current_x, current_y, @depth, door_angle)
            if args.state.rng.d6 > 5
              door.openness = 1.0
            end
            door.breakable = 4 + args.state.rng.d8 + args.state.rng.d8  # door can be broken with enough force
            # if args.state.rng.d8 == 12
            #   door.locked = true
            # end
            if args.state.rng.d8 == 1
              door.stuck = args.state.rng.d12 + 8 # door is stuck, needs strength test to open
            end
            @furniture << door
            @tiles[current_y][current_x] = new_tile if current_tile == :rock || current_tile == :wall
            next
          end
        end
      end
      if current_tile == :water
        new_tile = :water
      end
      if current_tile == :staircase_up || current_tile == :staircase_down
        new_tile = current_tile # keep the staircase tile
      end
      # terraform the tile - importat part!!!
      @tiles[current_y][current_x] = new_tile if new_tile
      # decide direction to next tile
      # if we have a direction, keep going that way with some chance
      if direction
        if args.state.rng.d20 < 4
          # keep going same direction
          next
        end
      end
      # otherwise or if no direction yet,
      # see which direction gets us closer to target
      y_diff = (y2 - current_y).abs
      x_diff = (x2 - current_x).abs
      if x_diff > y_diff
        if current_x < x2
          direction = :east
        elsif current_x > x2
          direction = :west
        else
          if current_y < y2
            direction = :north
          elsif current_y > y2
            direction = :south
          end
        end
      elsif y_diff > x_diff
        if current_y < y2
          direction = :north
        elsif current_y > y2
          direction = :south
        else
          if current_x < x2
            direction = :east
          elsif current_x > x2
            direction = :west
          end
        end
      else
        # equal distance, pick horizontal first 
        if current_x != x2
          if current_x < x2
            direction = :east
          elsif current_x > x2
            direction = :west
          end
        elsif current_y != y2
          if current_y < y2
            direction = :north
          elsif current_y > y2
            direction = :south
          end
        end
      end
    end
    printf "  finished digging corridor.\n"
  end

  def create_corridors(args)
    # Code to create corridors between rooms
    # 
    # first let's dig a corridor to exit

    #
    # every room has 1 to 2 corridors to other rooms
    # every corridor leads to a random point in another room
    distances_from_room_to_room = {}
    # calculate distances between rooms
    @rooms.each_with_index do |room_a, index_a|
      distances_from_room_to_room[index_a] ||= {}
      @rooms.each_with_index do |room_b, index_b|
        next if index_a == index_b
        distance = Math.sqrt((room_a.center_x - room_b.center_x)**2 + (room_a.center_y - room_b.center_y)**2)
        distances_from_room_to_room[index_a][index_b] = distance
      end
    end

    rooms_without_corridors = @rooms.dup
    corridors = []

    while rooms_without_corridors.size > 0 do
      room = rooms_without_corridors.first
      room_index = @rooms.index(room)
      possible_targets = distances_from_room_to_room[room_index].sort_by { |index_b, distance| distance }
      # create single corridor to nearest room
      target_room_index = possible_targets.first[0]
      target_room = @rooms[target_room_index]
      x1 = room.center_x
      y1 = room.center_y
      x2 = target_room.center_x
      y2 = target_room.center_y
      dig_corridor(args, x1, y1, x2, y2)
      corridors << [room, target_room]
      rooms_without_corridors.delete(room)
      rooms_without_corridors.delete(target_room) if rooms_without_corridors.include?(target_room)
    end 

    # now every room has a corridor to another room, but there is no way to be sure that all rooms are connected
    # we need to enforce that there is a way from any room to any other room (checked from corridors array)
    @rooms.each do |room|
      other_rooms = @rooms.dup
      # find if there is a way to reach this 
      reachable_rooms = [room]
      safety = 0
      while true do
        safety += 1
        if safety > 100
          printf "  Corridor connectivity check aborted due to safety limit.\n"
          break
        end
        newly_reached = []
        reachable_rooms.each do |r_room|
          corridors.each do |corridor|
            if corridor[0] == r_room && !reachable_rooms.include?(corridor[1])
              newly_reached << corridor[1]
            elsif corridor[1] == r_room && !reachable_rooms.include?(corridor[0])
              newly_reached << corridor[0]
            end
          end
        end
        break if newly_reached.size == 0
        reachable_rooms += newly_reached
      end
      unreachable_rooms = other_rooms - reachable_rooms
      if unreachable_rooms.size > 0
        # need to connect to one of the unreachable rooms
        target_room = unreachable_rooms.sample
        x1 = room.center_x
        y1 = room.center_y
        x2 = target_room.center_x
        y2 = target_room.center_y
        dig_corridor(args, x1, y1, x2, y2)
        corridors << [room, target_room]
        printf "  added extra corridor to connect unreachable room at (%d,%d)\n" % [target_room.x, target_room.y]
      end
    end
  end

  def add_waters(args)
    water_modifier = -2
    case @vibe
    when :swamp
      water_modifier = 2
    when :water
      water_modifier = 4
    end
    # how many water ellipses to create?
    water_ellipses = Numeric.rand(3..6) + water_modifier
    water_ellipses.times do
      center_x = Numeric.rand(1...(@tiles[0].size - 1)).to_i
      center_y = Numeric.rand(1...(@tiles.size - 1)).to_i
      radius_x = Numeric.rand(1..8).to_i + water_modifier
      radius_y = Numeric.rand(1..8).to_i + water_modifier
      for i in (center_y - radius_y)..(center_y + radius_y)
        for j in (center_x - radius_x)..(center_x + radius_x)
          # check level boundaries
          next if i < 1 || i >= @tiles.size - 1
          next if j < 1 || j >= @tiles[0].size - 1
          dx = j - center_x
          dy = i - center_y
          if ((dx * dx) * (radius_y * radius_y) + (dy * dy) * (radius_x * radius_x)) <= (radius_x * radius_x) * (radius_y * radius_y)
            if @tiles[i][j] == :floor 
              @tiles[i][j] = :water
            end
          end
        end
      end
    end
  end


  def add_effect(kind, x, y, args)
    effect_duration = 1.0 # default duration
    effect = Effect.new(kind, x, y, effect_duration)
    self.effects << effect
  end

  def apply_effects(args)
    # apply timed effects on the room tiles
    self.effects.each do |effect|
      effect.update
      if effect.duration_remaining <= 0
        self.effects.delete(effect)
      end
    end
  end

  def trapped_at?(x, y, args)
    return false unless @traps
    @traps.each do |trap|
      if trap.x == x && trap.y == y
        return true
      end
    end
    return false
  end

  def item_at(x, y)
    @items.each do |item|
      if item.x == x && item.y == y
        return item
      end
    end
    return nil
  end

end
