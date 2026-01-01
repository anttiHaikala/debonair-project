# never instantiated
class Species
  def self.npc_species    
    [
      :goblin, 
      :grid_bug, 
      :rat,
      :wraith,
      :skeleton,
      :minotaur,
      :orc,
      :leprechaun,
      :newt,
      :troll,
      :raccoon,
      :gelatinous_cube
    ]
  end
  def self.hero_species
      [
      :human,
      :elf,
      :dwarf,
      :orc,
      :halfling,
      :dark_elf,
      :goblin,
      :troll,
      :duck # glorantha style
    ]
  end

  def self.undead_species
    [
      :skeleton,
      :wraith
    ]
  end

  def self.mammal_body_parts
    [
      :head,
      :right_foreleg,
      :upper_torso,
      :left_foreleg,
      :lower_torso,
      :right_hind_leg,
      :left_hind_leg
      # :heart,
      # :lungs,
      # :brain,
      # :left_front_foot,
      # :right_front_foot,
      # :left_hind_foot,
      # :right_hind_foot,
      # :left_front_leg,
      # :right_front_leg,
      # :left_hind_leg,
      # :right_hind_leg,
      # :spine,
      # :left_eye,
      # :right_eye,
      # :liver,
      # :left_kindey,
      # :right_kidney,
      # :intestines,
      # :stomach,
      # :colon,
      # :left_hip,
      # :right_hip,
      # :left_thigh,
      # :right_thigh,
      # :left_calf,
      # :right_calf,
      # :nozzle,
      # :left_ear,
      # :right_ear,
      # :left_temple,
      # :right_temple,
      # :top_of_skull,
      # :forehead,
      # :jaw,
      # :back_of_skull      
    ]
  end

  def self.bug_body_parts
    [
      :head,
      :right_foreleg,
      :left_foreleg,
      :front_body,
      :right_middle_leg,
      :middle_body,
      :left_middle_leg,
      :right_rear_leg,
      :left_rear_leg,
      :rear_body

      # :head,
      # :thorax,
      # :abdomen,
      # :left_front_leg,
      # :right_front_leg,
      # :left_middle_leg,
      # :right_middle_leg,
      # :left_hind_leg,
      # :right_hind_leg,
      # :left_antenna,
      # :right_antenna,
      # :left_wing,
      # :right_wing,
      # :mandibles,
      # :eyes
    ]
  end

  # let's map the hit locations in a hierarchy:
  # - on top level we have the BIG SEVEN body parts of a humanoid
  # - every one of these body parts is further divided to more exact locations
  # - need some cool way to name these levels
  # - also need to figure out the direction of a hit (front, back, left, right, up, down)
  # - this will help in determining which body part is hit based on attack direction and angle

  def self.humanoid_hit_locations
    [
      :head,
      :right_arm,
      :upper_torso,
      :left_arm,
      :lower_torso,
      :right_leg,
      :left_leg
      # :left_knee,
      # :right_knee,
      # :left_foot,
      # :right_foot,
      # :left_elbow,
      # :right_elbow,
      # :left_hand,
      # :right_hand,
      # :back,
      # :left_eye,
      # :right_eye,
      # :stomach,
      # :genitals,
      # :teeth,
      # :left_hip,
      # :right_hip,
      # :left_thigh,
      # :right_thigh,
      # :left_shoulder,
      # :right_shoulder,
      # :nose,
      # :left_ear,
      # :right_ear,
      # :left_ankle,
      # :right_ankle,
      # :left_bicep,
      # :right_bicep,
      # :left_forearm,
      # :right_forearm,
      # :left_temple,
      # :right_temple,
      # :top_of_skull,
      # :forehead,
      # :jaw,
      # :left_cheek,
      # :right_cheek,
      # :back_of_skull
    ]
  end

  def self.color_for_species(species)
    case species
    when :goblin, :orc
      return [120, 80, 70]
    when :newt
      return [90, 100, 100]
    when :grid_bug
      return [330, 100, 100]
    when :rat
      return [80, 80, 20]
    when :wraith
      return [240, 0, 50]
    when :skeleton
      return [60, 0, 90]
    when :minotaur
      return [20, 80, 50]
    when :leprechaun
      return [120, 205, 120]
    when :troll
      return [100, 80, 40]
    when :raccoon
      return [30, 80, 60]
    when :gelatinous_cube
      return [180, 50, 90]
    else
      return [255, 255, 255]
    end
  end
end