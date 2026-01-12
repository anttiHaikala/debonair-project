class Food < Item
  # Blueprint data for all non-corpse food items
  # condition: 1.0 (fresh) to 0.0 (deadly poisonous)
  # spoil_rate: decimal points lost per tick (e.g., 0.00001 for slow decay)
  # nutrition: decimal percentage of hunger bar (0.0 to 1.0)
DATA = {
    food_ration: {
      nutrition: 0.25, weight: 1.0, price: 20,
      meta: { ui_name: "food ration", description: "A standard-issue preserved meal. Keeps you alive.", condition: 1.0, spoil_rate: 0.0, occurance: 1.0 }
    },
    hamburger: {
      nutrition: 0.20, weight: 0.8, price: 15,
      meta: { ui_name: "hamburger", description: "Tasty burger with sesame seed bun.", condition: 1.0, spoil_rate: 0.000001, occurance: 0.3 }
    },
    dried_meat: {
      nutrition: 0.15, weight: 0.5, price: 15,
      meta: { ui_name: "dried meat", description: "Salty and tough. It'll last forever in your pack.", condition: 1.0, spoil_rate: 0.000001, occurance: 0.8 }
    },
    apple: {
      nutrition: 0.05, weight: 0.2, price: 5,
      meta: { ui_name: "apple", description: "A crisp, red apple. Watch out for worms.", condition: 1.0, spoil_rate: 0.00001, occurance: 0.6 }
    },
    lembas: {
      nutrition: 0.30, weight: 0.1, price: 100,
      meta: { ui_name: "lembas wafer", description: "Elven waybread. One small bite is enough to fill the stomach of a hungry hobbit.", condition: 1.0, spoil_rate: 0.0, occurance: 0.1 }
    },
    vegetables: {
      nutrition: 0.05, weight: 0.3, price: 3,
      meta: { ui_name: "leafy greens", description: "Nice vegan food option for hungry adventurer.", condition: 1.0, spoil_rate: 0.0002, occurance: 0.6 }
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
      meta: { ui_name: "slime mold", description: "An exotic, pulsating growth. It tastes like... purple?", condition: 1.0, spoil_rate: 0.0005, occurance: 0.3 }
    },
    blood_pack: {
      nutrition: 0.2, weight: 1, price: 100,
      meta: { ui_name: "blood pack", description: "1 liter of blood.", condition: 1.0, spoil_rate: 0.0001, occurance: 0.1 }
    },
    bird_food: {
      nutrition: 0.3, weight: 0.1, price: 10,
      meta: { ui_name: "bird food", description: "A small, surprisingly nutritious meal for titmouses.", condition: 1.0, spoil_rate: 0.000001, occurance: 0.3 }
    },
    vomit: {
      nutrition: 0.2, weight: 1, price: 0,
      meta: { ui_name: "vomit", description: "This food item appears when someone eats too much.", condition: 0.2, spoil_rate: 0.001, occurance: 0.0001 }
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
    start_hunger = entity.hunger
    entity.hunger -= @nutrition*current_condition(args)
    vomit = false
    # Remove from inventory
    entity.carried_items.delete(self)
   
    # Check condition
    cond = current_condition(args)
    if cond > 0.4
      HUD.output_message(args, "You eat the #{self.title(args)}.  It seems #{describe(args)}. It tastes #{@taste}!")
    # Food with bad condition can cause poisoning or vomit
    else
      HUD.output_message(args, "You eat the #{self.title(args)}.  It seems #{describe(args)} and tastes like it!")
      #cheking possible vomiting and poisoning
      food_poisoning_roll =  args.state.rng.d20 + cond*10
      if food_poisoning_roll < 5
        Status.new(entity, :poisoned, 10 + args.state.rng.d10, args)
        SoundFX.play_sound(:hero_hurt, args)
        HUD.output_message args, "#{entity.name} is poisoned by #{self.title(args)}!"
      elsif food_poisoning_roll < 10
        HUD.output_message(args, "Uhhh... you feel so bad after eating that crap...")
        vomit = true
      end
    end
    
    #entity.hunger = 0.0 if entity.hunger < 0.0
    # testing vomiting instead of setting hunger to 0
    if entity.hunger < -0.25
      # hero has not been warned about over eating
      if start_hunger > 0
        HUD.output_message(args, "Your tummy is so full you must stop eating")
        entity.hunger = 0
      # hero has been warn
      else
        HUD.output_message(args, "BLUAAAAGH!!! You ate too much!")
        vomit = true
      end
    elsif entity.hunger < -0.20
      HUD.output_message(args, "You feel reeeally nauseous because of eating so much.")
    elsif entity.hunger < 0
      HUD.output_message(args, "Careful there! Your tummy is full!")
      entity.hunger = 0.0 # Cap at full if not yet nauseous
    end

    if vomit
        HUD.output_message(args, "You vomit!")
        entity.hunger = 0.6 
        vomit_item = Food.new(:vomit)
        level = args.state.dungeon.levels[args.state.hero.depth]
        vomit_item.x = args.state.hero.x
        vomit_item.y = args.state.hero.y
        level.items << vomit_item 
    end

    # Check if food is poisonous kind 
    if self.attributes.include?(:poisonous)
        Status.new(entity, :poisoned, 10 + args.state.rng.d10, args)
        SoundFX.play_sound(:hero_hurt, args)
        HUD.output_message args, "#{self.title(args)} meat is poisonous!"
    end
    return true
  end
  
  # Dynamically calculate the condition based on elapsed ticks
  # NOT IMPLEMENTED: poisoning from food
  def current_condition(args)
    return @condition if @spoil_rate == 0
    elapsed = args.state.tick_count - @created_at
    decay = elapsed * @spoil_rate
    [(@condition - decay), 0.0].max
  end

  def describe(args)
    fresh = ["fresh", "safe", "ok"]
    old = ["kind of eatable", "had a bit funky aroma", "that is has seen better days", "ok...ish"]
    rotten = ["it contains some extra protein from maggots", "...wait! Do you have toilet paper?", "rotten"]
    really_bad = ["something one should not eat", "like a vey bad idea", "a great candidate for getting a hefty poisoning"]
    cond = current_condition(args)
    
    status = if cond > 0.8 then fresh.sample
             elsif cond > 0.4 then old.sample
             elsif cond > 0.1 then rotten.sample
             else really_bad.sample
             end
    status
  end

  def self.randomize(level_depth, args)
    Item.randomize(level_depth, self, args)
  end
end

class Corpse < Food
  # Spoil rates for corpses are significantly higher than preserved food
  # these are separate from the ones that are created from npcs.
  CORPSE_DATA = {
    mummified_corpse: { nutrition: 0.2, weight: 10, meta: { ui_name: "mummified corpse", description: "Someone who has died a long time ago. Good source for ancient dried meat.", condition: 1.0, spoil_rate: 0.00000001 } },
    brain: { nutrition: 0.4, weight: 2, meta: { ui_name: "brain", description: "A gray, wrinkled organ is yummy for zombie tommy.", condition: 1.0, spoil_rate: 0.002 } }
  }

  #custom data is used when generated from npc
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
    # Moved kind assignment outside the hash literal to fix the syntax error
    kind = "#{npc.species}_corpse"
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
    if npc.is_eatable
      corpse = self.new(kind, args, data)
      # poison is now done with attribute but if attributes will alwaus be visible for player this is a problem
      poison_roll = args.state.rng.rand
      if poison_roll > npc.is_eatable
        corpse.add_attribute(:poisonous)
      end
      corpse
    else
      Item.new(:useless_carcas, args)
    end 
  end

  def self.kinds
    CORPSE_DATA.keys
  end
end