# 
# Maslov's hierarchy of needs
# 1. self-actualization
# 2. self-esteem
# 3. love and belonging
# 4. safety and security
# 5. physiological needs
# 
# Pikemon's menu of dungeon needs
# 
# 1. avoid being hit (survival need)
# 2. eat (hunger)
# 3. drink (thirst)
# 4. physical rest (physical fatigue)
# 5. sleep (sleep deprivation)
# 6. mental rest (mental fatigue)
# 7. stocking up supplies (safety need)
# 8. explore (novelty)
# 9. socialize (loneliness)
class Need

  attr_accessor :kind, :score

  def self.increase amount
    @score += amount
  end

  def self.decrease amount
    @score -= amount
    if @score < 0
      @score = 0
    end
  end  

  def self.kinds
    [
      :avoid_being_hit,
      :hunger,
      :thirst,
      :physical_fatigue,
      :sleep_deprivation,
      :mental_fatigue,
      :safety,
      :novelty,
      :company
    ]
  end
end

module Needy
  attr_accessor :needs
  def initialize_needs
    @needs = {}
  end

  def need_score(kind)
    score = @needs[kind] || 0
    return score
  end

  def increase_need(kind, amount=1)
    printf "Increasing need #{kind} of #{@kind} by #{amount}\n"
    if @needs[kind]
      @needs[kind] += amount
    else
      @needs[kind] = amount
    end
  end

  def decrease_need(kind, amount=1)
    @needs[kind] ||= 0
    @needs[kind] -= amount
    if @needs[kind] < 0
      @needs[kind] = 0
    end
  end
end

