# Debonair Trauma System has the following main ideas: 
# - focus on discrete wounds that tell a story, not on generic hit points
# - traumas affect character capabilities in a realistic or at least logical fashion
# - causes of death should be at least quasi-realistic
# - before death, there are many levels of incapacitation (shock, unconsciousness etc.)
# - hit location of the trauma matters a lot (concussion to head -> unconsciousness, cut to arm -> dropped weapon etc)
# - no need to be 100% realistic, emphasis on immersion and storytelling
# NOTES: 
# - emotional traumas should possibly be moved to a separate system!
# - some physical traumas can have emotional side effects (e.g. disfigurement -> depression, loss of limb -> anxiety etc)
# - some phsyical traumas like head hits have mental effeccts (concussion -> confusion, dizziness etc)
# - what kind of trauma is lethal? make a list
# - how to handle bleeding?
# - no intrisic healing over time, healing only via treatment (time scale of game is too short)
#
# BLUNT TRAUMA EFFECT MATRIX
# 
# BODY PART.              MINOR.           MODERATE.          SEVERE.            CRITICAL.
# Head                    headache         concussion         unconsciousness    death
# Upper torso             bruising         cracked ribs                          punctured lung
# Lower torso             bruising         internal bleeding  organ failure      death
# Right Arm               pain             limited use        unusable           amputation
# Left Arm                pain             limited use        unusable           amputation
# Right Leg               pain             limp               cannot walk        amputation
# Left Leg                pain             limp               cannot walk        amputation
# 
# CUT TRAUMA EFFECT MATRIX
# 
# BODY PART.              MINOR.           MODERATE.          SEVERE.            CRITICAL.
# Head                    bleeding         bleeding           minor fracture     major fracture
# Upper torso             bleeding         bleeding
# Lower torso             bleeding         internal bleeding  organ failure      death
# Right Arm               bleeding         limited + bleed    unusable + bleed   amputation
# Left Arm                bleeding         limited + bleed    unusable + bleed   amputation
# Right Leg               bleeding         limp+bleed         cannot walk        amputation
# Left Leg                bleeding         limp+bleed         cannot walk        amputation
#
# PIERCE TRAUMA EFFECT MATRIX
# 
# BODY PART.              MINOR.           MODERATE.          SEVERE.            CRITICAL.
# Head                    bleeding         bleeding + pain    concussion+bleed   death
# Upper torso             bruising         cracked ribs       punctured lung     death
# Lower torso             bruising         internal bleeding  organ failure      death
# Right Arm               pain             limited use        unusable           amputation
# Left Arm                pain             limited use        unusable           amputation
# Right Leg               pain             limp               cannot walk        amputation
# Left Leg                pain             limp               cannot walk        amputation
#
# BURN TRAUMA EFFECT MATRIX
# 
# BODY PART.              MINOR.           MODERATE.          SEVERE.            CRITICAL.
# Head                    headache         concussion         unconsciousness    death
# Upper torso             bruising         cracked ribs       punctured lung     death
# Lower torso             bruising         internal bleeding  organ failure      death
# Right Arm               pain             limited use        unusable           amputation
# Left Arm                pain             limited use        unusable           amputation
# Right Leg               pain             limp               cannot walk        amputation
# Left Leg                pain             limp               cannot walk        amputation
#
#
#
class Trauma
  attr_reader :kind, :category, :treatments, :body_part, :last_treated, :severity, :entity
  def initialize(kind, body_part, severity, entity)
    @kind = kind
    @category = Trauma.kinds.find { |cat, kinds| kinds.include?(kind) }&.first
    @treatments = []
    @body_part = body_part
    @severity = severity
    @last_treated = nil # simulation time when applied
    @entity = entity
  end

  def self.categories
    [:physical, :mental, :emotional]
  end

  def self.severities
    [:healed, :minor, :moderate, :severe, :critical]
  end

  def self.treatments
    [:none, :harmful, :useless, :basic, :professional, :magical, :miraculous]
  end

  def self.kinds
    {
      physical: [:cut, :blunt, :pierce, :fracture, :burn, :frostbite, :sprain, :bite, :internal_injury, :poison, :electric, :magic],
      mental: [:concussion, :stress],
      emotional: [:grief, :anxiety, :fear, :depression]
    }
  end

  def self.trauma_score(entity, args)
    score = 0
    entity.traumas.each do |t|
      score += t.numeric_severity
    end
    return score
  end

  def heal_one_step
    case @severity
    when :critical
      @severity = :severe
    when :severe
      @severity = :moderate
    when :moderate
      @severity = :minor
    when :minor
      @severity = :healed
    when :cosmetic
      @severity = :healed
    end
    # check for shock recovery
    if entity.has_status?(:shocked)
      still_shocked = Trauma.determine_shock(entity)  
      unless still_shocked
        entity.remove_status(:shocked)
      end
    end
  end

  def numeric_severity
    case @severity
    when :healed
      return 0
    when :cosmetic # just a scratch, but this can be important for magical effects, poisoning, infection etc
      return 0
    when :minor # more than just a scratch!
      return 1
    when :moderate
      return 2
    when :severe
      return 4
    when :critical
      return 8
    else
      return 0
    end
  end

  def self.inflict(entity, body_part, kind, severity, args)
    category = kinds.find { |cat, kinds| kinds.include?(kind) }&.first
    raise 'Unknown trauma kind' unless category
    # check for "protection" items
    entity.worn_items.each do |item|
      if item.protects_against_trauma?(kind)
        HUD.output_message args, "#{entity.name.capitalize}'s #{item.name} protects against #{kind} trauma!"
        return nil
      end
    end
    trauma = Trauma.new(kind, body_part, severity, entity)
    trauma.instance_variable_set(:@body_part, body_part)  
    entity.traumas << trauma
    printf "Inflicted #{kind} trauma to #{entity.class} at #{body_part}. Has now #{entity.traumas.size} traumas.\n"
    self.apply_effects(entity, trauma, args)
    SoundFX.play(:trauma, args)
    return trauma
  end

  def self.apply_effects(entity, trauma, args)
    entity.increase_need(:avoid_being_hit)
    if trauma.severity != :minor
      if [:right_hand, :right_fingers, :right_arm].include? trauma.body_part
        if entity.wielded_items.any?
          dropped_item = entity.wielded_items.first
          entity.drop_item(dropped_item, args)          
          printf "Entity dropped wielded item due to hand trauma.\n"
        end
      end
      if trauma.body_part == :left_arm
        if entity.wielded_items.size > 1
          dropped_item = entity.wielded_items[1]
          entity.drop_item(dropped_item, args)
          printf "Entity dropped wielded item due to hand trauma.\n"
        end
      end 
    end
    shocked = self.determine_shock(entity)
    if shocked
      entity.go_into_shock(args)
    end
    dead = self.determine_morbidity(entity)
    if dead
      entity.perish(args)
    end
  end

  def self.determine_shock(entity)
    if entity.undead?
      return false
    end
    if entity.has_trait?(:zombie)
      return false
    end
    shock_score = 0
    shock_threshold = 3 # TODO: shock threshold should be character specific
    entity.traumas.each do |trauma|
      case trauma.severity
      when :minor
        shock_score += 0
      when :moderate
        shock_score += 1
      when :severe
        shock_score += 2
      when :critical
        shock_score += 3
      end
    end
    if shock_score >= shock_threshold
      return true
    else
      return false
    end
  end

  def self.determine_morbidity(entity)
    printf "Determining morbidity for entity with %d traumas.\n" % [entity.traumas.size]
    death_score = 0
    death_threshold = 10 # TODO: death threshold should be character specific
    entity.traumas.each do |trauma|     
      case trauma.severity
      when :minor
        death_score += 0
      when :moderate
        death_score += 2
      when :severe
        death_score += 3
      when :critical
        death_score += 6
      end    
    end
    printf "Total death score is %d (threshold %d).\n" % [death_score, death_threshold]
    if death_score >= death_threshold
      return true
    else
      return false
    end
  end

  def self.body_parts_counted_for_death
    [:head, :torso, :heart, :lungs, :brain, :spine, :abdomen, :forehead, :top_of_skull, :back_of_skull, :colon, :intestines, :stomach, :genitals, :left_temple, :right_temple, :thorax, :eyes, :left_eye, :right_eye, :right_calf, :left_calf, :right_thigh, :left_thigh]
  end

  def self.active_traumas(entity)
    return entity.traumas.select { |trauma| trauma.severity != :healed }
  end

  def title(args)
    "#{@severity.to_s.capitalize} #{@kind.to_s.gsub('_',' ')} on #{@body_part.to_s.gsub('_',' ')}"
  end

  def self.walking_speed_modifier(entity)
    speed_modifier = 1.0
    active_traumas(entity).each do |trauma|
      case trauma.body_part
      when :left_leg, :right_leg, :left_knee, :right_knee, :left_foot, :right_foot, :left_hip, :right_hip, :left_thigh, :right_thigh, :left_calf, :right_calf, :toes_of_left_foot, :toes_of_right_foot
        case trauma.severity
        when :minor
          speed_modifier -= 0.05
        when :moderate
          speed_modifier -= 0.1
        when :severe
          speed_modifier -= 0.2
        when :critical
          speed_modifier -= 0.3
        end
      end
    end
    if speed_modifier < 0.1
      speed_modifier = 0.1
    end
    if speed_modifier > 1.0
      speed_modifier = 1.0
    end
    return speed_modifier
  end
end

class Entity
  def go_into_shock(args)
    unless self.has_status?(:shocked)
      Status.new(self, :shocked, nil, args)
      self.drop_wielded_items(args) # add randomness later
      self.feel(:afraid, args)
      HUD.output_message(args, "#{self.name.capitalize} goes into shock!")
    end
  end
end