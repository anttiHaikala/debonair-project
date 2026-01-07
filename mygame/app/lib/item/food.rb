class Food < Item
  # Blueprint data for all non-corpse food items
  # condition: 1.0 (fresh) to 0.0 (deadly poisonous)
  # spoil_rate: decimal points lost per tick (e.g., 0.00001 for slow decay)
  # nutrition: decimal percentage of hunger bar (0.0 to 1.0)
DATA = {
    food_ration: {
      nutrition: 0.25, weight: 1.0, price: 20,
      meta: { ui_name: "food ration", description: "A standard-issue preserved meal. Not tasty, but keeps you alive.", condition: 1.0, spoil_rate: 0.0, occurance: 1.0 }
    },
    hamburger: {
      nutrition: 0.20, weight: 0.8, price: 15,
      meta: { ui_name: "hamburger", description: "Tasty burger with sesame seed bun.", condition: 1.0, spoil_rate: 0.0, occurance: 0.3 }
    },
    dried_meat: {
      nutrition: 0.15, weight: 0.5, price: 15,
      meta: { ui_name: "dried meat", description: "Salty and tough. It'll last forever in your pack.", condition: 1.0, spoil_rate: 0.00001, occurance: 0.8 }
    },
    apple: {
      nutrition: 0.05, weight: 0.2, price: 5,
      meta: { ui_name: "apple", description: "A crisp, red apple. Watch out for worms.", condition: 1.0, spoil_rate: 0.0001, occurance: 0.6 }
    },
    lembas: {
      nutrition: 0.50, weight: 0.1, price: 100,
      meta: { ui_name: "lembas wafer", description: "Elven waybread. One small bite is enough to fill the stomach of a hungry hobbit.", condition: 1.0, spoil_rate: 0.0, occurance: 0.1 }
    },
    vegetables: {
      nutrition: 0.03, weight: 0.3, price: 3,
      meta: { ui_name: "leafy greens", description: "Surprisingly fresh-looking vegetables.", condition: 1.0, spoil_rate: 0.0002, occurance: 0.6 }
    },
    canned_food: {
      nutrition: 0.20, weight: 1.5, price: 30,
      meta: { ui_name: "tin of food", description: "Heavy and sealed tight. You might need a tool to open this.", condition: 1.0, spoil_rate: 0.0, occurance: 0.4 }
    },
    fortune_cookie: {
      nutrition: 0.01, weight: 0.1, price: 2,
      meta: { ui_name: "fortune cookie", description: "A crunchy snack containing a small, mysterious message.", condition: 1.0, spoil_rate: 0.0, occurance: 0.5 }
    },
    slime_mold: {
      nutrition: 0.08, weight: 0.4, price: 10,
      meta: { ui_name: "slime mold", description: "An exotic, pulsating growth. It tastes like... purple?", condition: 1.0, spoil_rate: 0.00005, occurance: 0.3 }
    },
    blood_pack: {
      nutrition: 0.08, weight: 1, price: 100,
      meta: { ui_name: "blood pack", description: "1 liter of blood.", condition: 1.0, spoil_rate: 0.0001, occurance: 0.1 }
    },
    bird_food: {
      nutrition: 0.5, weight: 0.1, price: 10,
      meta: { ui_name: "bird food", description: "A small, surprisingly nutritious meal for titmouses.", condition: 1.0, spoil_rate: 0.000001, occurance: 0.3 }
    }
  }

  attr_accessor :nutrition, :weight, :meta, :price, :occurance, :taste, :condition, :spoil_rate, :created_at, :description

  def initialize(kind, args = nil, category = :food, &block)
    blueprint = DATA[kind] || {nutrition: 0.5, weight: 0.1, price: 10, meta: {} }
    @meta = (blueprint[:meta] || {}).dup
    @nutrition = blueprint[:nutrition] || 0.05
    @weight = blueprint[:weight] || 0.5
   
    # Initialize condition (freshness) and spoil rate (how fast it rots)
    @condition = @meta[:condition] || 1.0
    @spoil_rate = @meta[:spoil_rate] || 0.0001
    
    # Timestamp the creation to calculate decay later
    @created_at = args ? args.state.tick_count : 0
    
    # Taste randomization for flavor
    tastes = [:yummy, :edible, :bland, :disgusting, :kinda_crap]
    @taste = args ? args.state.rng.sample(tastes) : tastes.sample
    @description = meta[:description]
    
    super(kind, category, &block)
  end

  # --- CLASS DATA ACCESS ---
  def self.data; DATA; end
  def self.kinds; DATA.keys; end
  
  def use(entity, args)
    return false unless entity.is_a?(Hero)
    
    # Reduce hunger
    entity.hunger -= @nutrition
    entity.hunger = 0.0 if entity.hunger < 0.0

    # Remove from inventory
    entity.carried_items.delete(self)
    
    HUD.output_message(args, "You eat the #{self.title(args)}. It tastes #{@taste}.")
    return true
  end
  
  # Dynamically calculate the condition based on elapsed ticks
  # NOT IMPLEMENTED: call this method before consumption to get current state
  def current_condition(args)
    return @condition if @spoil_rate == 0
    elapsed = args.state.tick_count - @created_at
    decay = elapsed * @spoil_rate
    [(@condition - decay), 0.0].max
  end

  def describe(args)
    desc = @meta[:description] || "A generic item of food."
    cond = current_condition(args)
    
    status = if cond > 0.8 then "fresh"
             elsif cond > 0.4 then "that it might be eatable"
             elsif cond > 0.1 then "better eat it before the maggots?"
             else "having...pretty funky armonas"
             end
    "#{desc} It seems #{status}."
  end

  def self.randomize(level_depth, args)
    Item.randomize(level_depth, self, args)
  end
end

class Corpse < Food
  # Spoil rates for corpses are significantly higher than preserved food
  CORPSE_DATA = {
    newt_corpse: { nutrition: 0.02, weight: 0.2, meta: { ui_name: "newt corpse", description: "A dead small, yummy lizard body.", condition: 1.0, spoil_rate: 0.0005 } },
    rat_corpse: { nutrition: 0.05, weight: 0.5, meta: { ui_name: "rat corpse", description: "A dead mid sized rodent.", condition: 1.0, spoil_rate: 0.0008 } },
    orc_corpse: { nutrition: 0.12, weight: 2.0, meta: { ui_name: "orc corpse", description: "The remains of a muscular humanoid. Smellely guy.", condition: 1.0, spoil_rate: 0.001 } },
    kobold_corpse: { nutrition: 0.04, weight: 0.8, meta: { ui_name: "kobold corpse", description: "A dead scaly, dog-like creature.", condition: 1.0, spoil_rate: 0.0008 } },
    brain: { nutrition: 0.03, weight: 0.3, meta: { ui_name: "brain", description: "A gray, wrinkled organ. Smells like amyloids and bad memories.", condition: 1.0, spoil_rate: 0.002 } }
  }

  def initialize(kind, args = nil, custom_data = nil)
    blueprint = custom_data || CORPSE_DATA[kind] || { 
      nutrition: 0.05, 
      weight: 1.0, 
      meta: { ui_name: "#{kind.to_s.gsub('_', ' ')} corpse", description: "The remains of a fallen creature.", condition: 1.0, spoil_rate: 0.001 } 
    }

    @nutrition = blueprint[:nutrition] || 0.05
    @weight = blueprint[:weight] || 1.0
    @meta = (blueprint[:meta] || {}).dup
    
    @condition = @meta[:condition] || 1.0
    @spoil_rate = @meta[:spoil_rate] || 0.001
    @created_at = args ? args.state.tick_count : 0
    super(kind, args, :corpse)
  end

  def self.create_from_npc(npc, args)
    data = {
      nutrition: (npc.weight * 0.02), 
      weight: npc.weight || 1.0,
      meta: {
        ui_name: "#{npc.species} corpse",
        description: "The fresh remains of #{npc.species}. It's still trembling.",
        condition: 1.0,
        spoil_rate: 0.001 
      }
    }
    self.new(npc.species, args, data)
  end

  def self.kinds
    CORPSE_DATA.keys
  end
end