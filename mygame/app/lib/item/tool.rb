class Tool < Item
  # Blueprint data for tools and accessories
  # Each tool has:
  #   UI Name
  #   Weight (in lbs)
  #   Price (in game currency)
  # Rarity: Common (100), Uncommon (50), Rare (10)
  DATA = {
    pickaxe: { durability: 10, action: :dig, is_crafted: nil, 
      meta: { ui_name: "pickaxe", weight: 4.5, price: 50, occurance: 0.1 }
    },
    lockpick: { durability: 8, action: :unlock, is_crafted: nil,
      meta: { ui_name: "lockpick set", weight: 0.2, price: 100,  occurance: 0.2 }
    },
    mirror: { durability: nil, action: :reflect, is_crafted: nil,
      meta: { ui_name: "mirror", weight: 0.5, price: 20,  occurance: 0.2 }
    },
    medkit: { durability: 1, action: :heal, is_crafted: nil,
      meta: { ui_name: "trauma medkit", weight: 1.2, price: 300,  occurance: 0.2 }
    },
    wings: { durability: nil, action: :fly, is_crafted: nil,
      meta: { ui_name: "wings", weight: 3.0, price: 500,  occurance: 0.0 }
    },
    battery_pack: { durability: nil, action: :recharge, is_crafted: nil,
      meta: { ui_name: "battery pack", weight: 3.0, price: 500, occurance: 0.5}
    },
    notebook: {  durability: 10, action: :copy_scroll, is_crafted: nil,
      meta: { ui_name: "notebook", weight: 3.0, price: 10, occurance: 0.05 }
    },
    air_fryer: { durability: 30, action: :cook, is_crafted: nil,
      meta: { ui_name: "air fryer", weight: 3, price: 100, occurance: 0.1}
    },
    camera: { durability: 30, action: :take_photo, is_crafted: nil,
      meta: { ui_name: "camera", weight: 0.5, price: 400, occurance: 0.05}
    },
    paper_clip: { durability: 30, action: :unlock, is_crafted: nil,
      meta: { ui_name: "air fryer", weight: 0.01, price: 1, occurance: 1}
    }
  }

  attr_accessor :meta, :durability

  def initialize(kind, args, &block)
      blueprint = DATA[kind] || {durability: nil, action: nil, meta: {} }

    @meta = blueprint[:meta].dup
    @weight = @meta[:weight] || 1.0
    @durability = blueprint[:durability] 
    @action = blueprint[:action]
    @is_crafted = blueprint[:is_crafted] 

    # Initialize Item parent
    super(kind, :tool, &block)
  end

  # --- CLASS DATA ACCESS ---
  def self.data; DATA; end
  def self.kinds; DATA.keys; end

  # Seeded randomization based on rarity weights
  def self.randomize(level_depth, args)
    total_rarity = DATA.values.map { |d| d[:meta][:rarity] || 100 }.sum
    roll = args.state.rng.nxt_int(0, total_rarity - 1)
    
    current_sum = 0
    DATA.each do |kind, data|
      current_sum += (data[:meta][:rarity] || 100)
      if roll < current_sum
        tool = self.new(kind, args)
        tool.depth = level_depth
        return tool
      end
    end
    self.new(:torch, args) # Fallback
  end

  def self.random(level_depth, args); self.randomize(level_depth, args); end

  def tool_action
    @meta[:action]
  end

  # Generic usage logic
  def use(user, args)
    return unless user == args.state.hero

    case tool_action
    when :dig
      HUD.output_message(args, "You use the #{self.title(args)} to clear the path.")
      # Logic: check if adjacent to wall, remove wall tile
    when :unlock
      HUD.output_message(args, "You carefully probe the mechanism with your #{self.title(args)}.")
      # Logic: check if adjacent to locked door, roll for success
    when :reflect
      HUD.output_message(args, "You hold the #{self.title(args)} up to the light.")
      # Logic: Reflect light or show hidden areas
    when :heal
      HUD.output_message(args, "You use the #{self.title(args)} to bind your wounds.")
      # Logic: Reduce traumas or restore HP
    else
      HUD.output_message(args, "You aren't sure how to use the #{self.title(args)} right now.")
      return false
    end

    # Reduce durability and handle breakage
    @durability -= 1
    if @durability <= 0
      user.carried_items.delete(self)
      # need to add messages for different tools, some just wear out, some break
      HUD.output_message(args, "The #{self.title(args)} breaks!")
    end

    true
  end
end