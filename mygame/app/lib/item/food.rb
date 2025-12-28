class Food < Item
  attr_accessor :nutrition_value, :taste

  def initialize(kind, args, category = :food)
    # Pass the kind and the specific category (:food or :corpse) to the Item class
    super(kind, category)
    
    setup_stats(kind)
    
    # Use the game's seeded RNG to pick a taste
    @taste = args.state.rng.sample(self.class.taste_classes)
  end

  def setup_stats(kind)
    case kind
    when :food_ration  then @nutrition_value = 0.25
    when :dried_meat   then @nutrition_value = 0.15
    when :fruit        then @nutrition_value = 0.10
    when :vegetables   then @nutrition_value = 0.10
    when :canned_food  then @nutrition_value = 0.20
    else                    @nutrition_value = 0.05
    end
  end

  def self.kinds
    [
      :food_ration,
      :dried_meat,
      :fruit,
      :vegetables,
      :canned_food
    ]
  end

  def self.taste_classes
    [:yummy, :edible, :bland, :disgusting, :kinda_crap]
  end

  def use(entity, args)
    return false unless entity.is_a?(Hero)
    
    # Reduce hunger
    entity.hunger -= @nutrition_value
    entity.hunger = 0.0 if entity.hunger < 0.0
    
    # Remove from inventory
    entity.carried_items.delete(self)
    
    HUD.output_message(args, "You eat the #{self.title(args)}. It tastes #{@taste}.")
    true
  end
end

class Corpse < Food
  def initialize(kind, args)
    # We call super but specifically identify as a :corpse category
    super(kind, args, :corpse)
  end

  def setup_stats(kind)
    case kind
    when :newt_corpse then @nutrition_value = 0.40
    when :rat_corpse  then @nutrition_value = 0.10
    when :orc_corpse then @nutrition_value = 0.80
    else                   @nutrition_value = 0.05
    end
  end

  # Overwrite so randomize(Corpse) only picks from these
  def self.kinds
    [
      :newt_corpse,
      :rat_corpse,
      :orc_corpse
    ]
  end

  # Corpses usually don't taste 'yummy' maybe ake exception for newt later
  def self.taste_classes
    [:bland, :disgusting, :kinda_crap, :rotten,:yummy_in_a_weird_way]
  end
end