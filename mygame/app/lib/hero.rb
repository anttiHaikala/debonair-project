class Hero < Entity

  attr_reader :role, :species, :trait, :age, :name

  def initialize(x, y)
    super(x, y)
    @kind = :pc
    @role = Hero.roles.sample
    @species = Hero.species.sample
    @trait = Hero.traits.sample
    @age = Hero.age.sample
    @name = 'Jaakko'
  end

  def self.roles
    [
      :archeologist, # maps and artifacts
      :cleric, # holiness
      :detective, # investigation and clues
      :druid, # spells and nature
      :mage, # classic spellcaster
      :monk, # martial arts and spirituality
      :ninja, # stealth and combat
      :rogue, # agility and trickery
      :samurai, # combat and honor
      :thief, # stealth and deception
      :tourist, # camera and confidence
      :warrior, # strength and bravery
    ]
  end

  def self.species
    [
      :human,
      :elf,
      :dwarf,
      :orc,
      :gnome,
      :halfling,
      :dark_elf,
      :goblin,
      :troll,
      :duck # glorantha style
    ]
  end

  def self.age
    [
      :teen,
      :adult,
      :elder
    ]
  end

  def self.traits
    [
      :undead,
      :mutant,
      :cyborg,      
      :alien,
      :robot,
      :vampire,
      :werewolf,
      :zombie,
      :demon,
      :angel
    ]
  end



end