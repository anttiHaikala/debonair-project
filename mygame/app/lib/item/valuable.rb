class Valuable < Item

  attr_accessor :value, :kind, :name, :appearance

  def initialize(kind:, value:)    
    super(kind, :valuable)
    @value = value
  end

  def title(args)
    self.name
  end

  def self.randomize(depth, args)
    value = case depth
            when 1,2,3 then args.state.rng.rand(50) + 50
            when 4,5,6 then args.state.rng.rand(100) + 200
            when 7,8,9 then args.state.rng.rand(300) + 300
            else args.state.rng.rand(1400) + 600
            end
    kind = [:jewel, :artifact].sample
    valuable = Valuable.new(kind: kind, value: value)
    if kind == :jewel
      jewels = ["ruby", "sapphire", "emerald", "diamond", "opal", "topaz", "amethyst"]
      valuable.name = jewels.sample
    else
      adjectives = ["ancient", "jeweled", "shimmering", "mystical", "satanic", "violet", "holy", "ornate", 'unholy', "delicate", 'fateful']
      adjective = adjectives.sample
      materials = ["gold", "silver", "ivory", "bronze", "obsidian", "jade", "crystal", "platinum", "pearl", "bone", 'wood']
      material = materials.sample
      substantives = ["trinket", "swan", "idol", "chalice", "scepter", "mask", "goblet", "statue", "seal", "feather", "minifigure", "card", "totem", "bowtie", "tiara", "lion", "dragon", "owl"]
      substantive = substantives.sample
      valuable.name = "#{adjective} #{material} #{substantive}"
    end
    return valuable
  end
end 