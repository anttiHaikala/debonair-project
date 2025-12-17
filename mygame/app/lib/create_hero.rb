class CreateHero

  @@species_index = 0
  @@age_index = 0
  @@trait_index = 0
  @@role_index = 0
  @@cursor_index = 0 # navigated with left/right

  def self.tick args
    self.handle_input args
    self.draw_static_elements args
    self.draw_hero_creation_interface args
  end

  def self.reset
    @@species_index = Numeric.rand(Hero.species.size)
    @@age_index = Numeric.rand(Hero.age.size)
    @@trait_index = Numeric.rand(Hero.traits.size)
    @@role_index = Numeric.rand(Hero.roles.size)
  end

  def self.handle_input args
    # confirm hero creation
    if args.inputs.keyboard.key_down.space || args.inputs.controller_one.key_down.a
      selected_age = Hero.age[@@age_index]
      selected_trait = Hero.traits[@@trait_index]
      selected_species = Hero.species[@@species_index]
      selected_role = Hero.roles[@@role_index]
      args.state.hero = Hero.new(selected_age, selected_trait, selected_species, selected_role)
      printf "Created new hero: %s\n" % args.state.hero.name
      Run.start_new_game args, args.state.hero
    end
    # cursor movement
    if args.inputs.keyboard.key_down.right || args.inputs.controller_one.right
      @@cursor_index += 1
      @@cursor_index = 0 if @@cursor_index > 3
    end
    if args.inputs.keyboard.key_down.left || args.inputs.controller_one.left
      @@cursor_index -= 1
      @@cursor_index = 3 if @@cursor_index < 0
    end
    if args.inputs.keyboard.key_down.up || args.inputs.controller_one.up
      case @@cursor_index
      when 0
        @@age_index -= 1
        @@age_index = Hero.age.size - 1 if @@age_index < 0
      when 1
        @@trait_index -= 1
        @@trait_index = Hero.traits.size - 1 if @@trait_index < 0
      when 2
        @@species_index -= 1
        @@species_index = Hero.species.size - 1 if @@species_index < 0
      when 3
        @@role_index -= 1
        @@role_index = Hero.roles.size - 1 if @@role_index < 0
      end
    end
    if args.inputs.keyboard.key_down.down || args.inputs.controller_one.down
      case @@cursor_index
      when 0
        @@age_index += 1
        @@age_index = 0 if @@age_index >= Hero.age.size
      when 1
        @@trait_index += 1
        @@trait_index = 0 if @@trait_index >= Hero.traits.size
      when 2
        @@species_index += 1
        @@species_index = 0 if @@species_index >= Hero.species.size
      when 3
        @@role_index += 1
        @@role_index = 0 if @@role_index >= Hero.roles.size
      end
    end
  end

  def self.draw_hero_creation_interface args
    top_margin = 270
    left_margin = 180
    column_width = 220
    line_heigth = 30
    culling = 2
    # draw selected hero attributes box
    args.outputs.primitives << {
      x: left_margin,
      y: 720-top_margin-line_heigth,
      w: 4 * column_width,
      h: 30,
      path: :solid,
      r: 50, g: 50, b: 50, a: 255
    }
    # draw four selection lists for hero creation, age, trait, species and profession
    Hero.age.each_with_index do |age, index|
      if index > @@age_index + culling || index < @@age_index - culling
        next
      end
      args.outputs.primitives << {
        x: left_margin + column_width * 0.5,
        y: 720-top_margin - (index * line_heigth) + @@age_index * line_heigth,
        width: column_width,
        path: :text,
        text: age,
        size_enum: 6,
        alignment_enum: 1,
        r: 255, g: 255, b: 255, a: 255
      }
    end
    Hero.traits.each_with_index do |trait, index|
      if index > @@trait_index + culling || index < @@trait_index - culling
        next
      end
      args.outputs.primitives << {
        x: left_margin + 1.5 * column_width,
        y: 720-top_margin - (index * line_heigth) + @@trait_index * line_heigth,  
        width: column_width,
        path: :text,
        text: trait,
        size_enum: 6,
        alignment_enum: 1,
        r: 255, g: 255, b: 255, a: 255
      }
    end
    Hero.species.each_with_index do |species, index|
      if index > @@species_index + culling || index < @@species_index - culling
        next
      end
      args.outputs.primitives << {
        x: left_margin + 2.5 * column_width,
        y: 720-top_margin - (index * line_heigth) + @@species_index * line_heigth,  
        width: column_width,
        path: :text,
        text: species.gsub("_", " "),
        size_enum: 6,
        alignment_enum: 1,
        r: 255, g: 255, b: 255, a: 255
      }
    end
    Hero.roles.each_with_index do |role, index|
      if index > @@role_index + culling || index < @@role_index - culling
        next
      end
      args.outputs.primitives << {
        x: left_margin + 3.5 * column_width,
        y: 720-top_margin - (index * line_heigth) + @@role_index * line_heigth,  
        width: column_width,
        path: :text,
        text: role,
        size_enum: 6,
        alignment_enum: 1,
        r: 255, g: 255, b: 255, a: 255
      }
    end
    # draw cursor
    args.outputs.primitives << {
      x: left_margin + @@cursor_index * column_width,
      y: 720-top_margin-line_heigth,
      w: column_width,
      h: line_heigth,
      path: :solid,
      r: 255,
      g: 255,
      b: 255,
      a: 100,
      blendmode_enum: 2
    }
  end

  def self.draw_static_elements(args)
    # background & title
    args.outputs.solids << { x: 0, y: 0, w: 1280, h: 720, path: :solid, r: 0, g: 0, b: 0, a: 255 }
    args.outputs.primitives << {
      x: 620,
      y: 650,
      w: 100,
      h: 100, 
      path: :text,
      text: "Create Hero",
      size_enum: 26,
      alignment_enum: 1,
      r: 255, g: 255,
      b: 255, a: 255,
      font: "fonts/greek-freak.ttf"
    }
    args.outputs.primitives << {
      x: 620,
      y: 220,
      w: 100,
      h: 100, 
      path: :text,
      text: "Press A or Space to Confirm",
      size_enum: 8,
      alignment_enum: 1,
      r: 255, g: 255,
      b: 255, a: 255,
      font: "fonts/greek-freak.ttf"
    }
  end
    
end

