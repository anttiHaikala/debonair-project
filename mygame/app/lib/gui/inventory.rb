class GUI

  def self.draw_items args
    level = Utils.level(args)
    return unless level
    tile_size = Utils.tile_size(args)
    level_height = Utils.level_height(args)
    level_width = Utils.level_width(args)
    x_offset = Utils.offset_x(args)
    y_offset = Utils.offset_y(args)
    level.items.each do |item|
      visible = Tile.is_tile_visible?(item.x, item.y, args)
      next unless visible
      lighting = level.lighting[item.y][item.x] # 0.0 to 1.0
      hue = item.color[0]
      saturation = item.color[1]
      brightness = item.color[2]
      brightness *= lighting
      color = Color::hsl_to_rgb(hue, saturation, brightness)
      args.outputs.sprites << {
        x: x_offset + item.x * tile_size,
        y: y_offset + item.y * tile_size,
        w: tile_size,
        h: tile_size,
        path: "sprites/sm16px.png",
        tile_x: item.c[0]*16,
        tile_y: item.c[1]*16,
        tile_w: 16,
        tile_h: 16,
        r: color[:r],
        g: color[:g],
        b: color[:b],
        a: 255
      }
    end
  end

  def self.handle_inventory_input args
    hero = args.state.hero
    @@menu_cooldown ||= 0
    if @@menu_cooldown > 0
      @@menu_cooldown -= 1
    end
    return unless hero
    if args.inputs.controller_one.key_held.r1 || args.inputs.keyboard.key_held.shift
      args.state.selected_item_index ||= 0
    else
      args.state.selected_item_index = nil
    end 
    if args.state.selected_item_index
      if args.inputs.up
        if @@menu_cooldown <= 0
          args.state.selected_item_index -= 1
          if args.state.selected_item_index < 0
            args.state.selected_item_index = hero.carried_items.size - 1
          end
          @@menu_cooldown = 5
        end
      elsif args.inputs.down
        if @@menu_cooldown <= 0
          args.state.selected_item_index += 1
          if args.state.selected_item_index >= hero.carried_items.size
            args.state.selected_item_index = 0
          end
          @@menu_cooldown = 5
        end
      elsif args.inputs.controller_one.key_down.left || args.inputs.keyboard.key_down.left
        # equip item to left hand
        selected_index = args.state.selected_item_index
        if selected_index >= 0 && selected_index < hero.carried_items.size
          item = hero.carried_items[selected_index]
          hero.wield_item(item, 1, args)
          SoundFX.play_sound(:equip_item, args)
          self.add_input_cooldown 10
          return true
        end
      elsif args.inputs.controller_one.key_down.right || args.inputs.keyboard.key_down.right
        # equip item to right hand
        selected_index = args.state.selected_item_index
        if selected_index >= 0 && selected_index < hero.carried_items.size
          item = hero.carried_items[selected_index]
          hero.wield_item(item, 0, args)
          SoundFX.play_sound(:equip_item, args)
          self.add_input_cooldown 10
          return true
        end
      elsif args.inputs.controller_one.key_down.a || args.inputs.keyboard.key_down.space
        # use selected item
        selected_index = args.state.selected_item_index
        if selected_index >= 0 && selected_index < hero.carried_items.size
          if hero.has_status?(:confused)
            if args.state.rng.d6 < 4
              # randomize item
              selected_index = args.state.rng.rand(hero.carried_items.size)
              HUD.output_message(args, "In your confused state, you fumble and use a random item!")
              SoundFX.play_sound(:fumble, args)
            end
          end
          item = hero.carried_items[selected_index]
          hero.use_item(item, args)
          SoundFX.play_sound(item.kind, args)
          self.add_input_cooldown 10
          return true
        end
      elsif args.inputs.controller_one.key_down.b || args.inputs.keyboard.key_down.enter
        # drop selected item
        selected_index = args.state.selected_item_index
        hero.drop_item(hero.carried_items[selected_index], args)
        args.state.selected_item_index -= 1
        if args.state.selected_item_index < 0
          args.state.selected_item_index = 0
        end
        SoundFX.play_sound(:drop_item, args)
        self.add_input_cooldown 10
        return true
      end
    end
  end
end