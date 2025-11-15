class Food < Item
  attr_accessor :nutrition_value, :taste

  def initialize(kind, args)
    super(kind, :food)
    case @kind
    when :food_ration
      @nutrition_value = 0.25
    when :dried_meat
      @nutrition_value = 0.15
    when :fruit
      @nutrition_value = 0.10
    when :vegetables
      @nutrition_value = 0.10
    when :canned_food
      @nutrition_value = 0.20
    else
      @nutrition_value = 0.05
    end
    self.taste = args.state.rng.sample(Food.taste_classes)
  end

  def use(entity, args)
    if entity.is_a?(Hero)
      entity.hunger -= @nutrition_value
      entity.hunger = 0.0 if entity.hunger < 0.0
      entity.carried_items.delete(self)
      HUD.output_message(args, "You eat the #{@kind.to_s.gsub('_',' ')}. It tastes #{self.taste}.")
      return true
    else
      return false
    end
  end

  def self.taste_classes
    [:yummy, :edible, :bland, :disgusting, :kinda_crap]
  end
end