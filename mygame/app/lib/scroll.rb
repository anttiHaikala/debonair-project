class Scroll < Item
  def initialize
    @title = "scroll of mapping"
    @description = "A magical scroll that glows with arcane energy."
    super(:scroll_of_mapping, :scroll)
  end

  def use(user, args)
    if user != args.state.hero
      return
    end
    HUD.output_message args, "You read the scroll. Mystical runes swirl around you!"
    Tile.auto_map_whole_level args    
  end
end