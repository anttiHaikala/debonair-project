class Score

  def self.high_score_list(args)
    args.state.high_scores ||= load_high_scores(args)
  end

  def self.save_high_scores(args)
    lines = args.state.high_scores.map { |s| "#{s.name}|#{s.score}|#{s.depth}|#{s.time_taken}|#{s.seed}" }
    args.gtk.write_file("high_scores.txt", lines.join("\n"))
  end

  def self.load_high_scores(args)
    data = args.gtk.read_file("high_scores.txt")
    return [] unless data
    scorez = data.split("\n").map do |line|
      name, score, depth, time_taken, seed = line.split("|")
      { name: name, score: score.to_i, depth: depth.to_i, time_taken: time_taken.to_i, seed: seed }
    end
    args.state.high_scores = scorez
    printf("Loaded high scores: %p\n", scorez.size)
    return scorez
  end

  def self.calculate(hero, args)
    time_used = args.state.kronos.world_time.to_i
    depth = hero.max_depth + 1
    score = 0
    hero.carried_items.each do |item|
      score += 5
      case item.category
      when :weapon
        score += 20
      when :armor
        score += 15
      when :potion
        score += 5
      when :scroll  
        score += 5
      when :ring
        score += 25
      when :amulet
        score += 50
      end
      item.attributes.each do |attr, value|
        if attr == :masterwork
          score += 100
        end
        if attr == :fine
          score += 20
        end
        if attr == :cursed
          score -= 50
        end
      end
    end
    if !hero.perished
      survival_modifier = 4.0
      hero.traumas.each do |trauma|
        if trauma.severity == :minor
          survival_modifier -= 0.1
        elsif trauma.severity == :major
          survival_modifier -= 0.3
        elsif trauma.severity == :severe
          survival_modifier -= 0.5
        elsif trauma.severity == :critical
          survival_modifier -= 0.7
        end
      end
      if survival_modifier < 1.0
        survival_modifier = 1.0
      end
    else
      survival_modifier = 0.5
    end
    score += hero.max_depth * 100
    score += 5000 if hero.has_item?(:amulet_of_skandor)
    # in the very end - survival modifier and time modifier
    score = (score.to_f * survival_modifier)
    # apply time penalty
    final_score = 100.0 * score / (100 + (time_used / 600.0))
    # round the final score DOWN to the nearest integer
    args.state.final_score = final_score.floor
    self.update_high_scores(hero.name, final_score.floor, depth, time_used, args.state.seed, args)
    return final_score
  end

  def self.update_high_scores(name, score, depth, time_taken, seed, args)
    printf("Updating high scores with %s: %d points, depth %d, time %d, seed %s \n", name, score, depth, time_taken, seed)
    high_scores = self.high_score_list(args)
    high_scores << { name: name, score: score, depth: depth, time_taken: time_taken, seed: seed }
    high_scores = high_scores.sort_by { |s| -s[:score] }
    high_scores = high_scores.first(10) # keep top 10
    args.state.high_scores = high_scores
    self.save_high_scores(args)
  end

  def self.tick args
    args.outputs.solids << { x: 0, y: 0, w: 1280, h: 720, path: :solid, r: 0, g: 0, b: 0, a: 255 }
    args.outputs.labels << {
      x: 640, y: 650, text: "Hi Scores", size_enum: 12, alignment_enum: 1, r: 255, g: 255, b: 255, font: "fonts/greek-freak.ttf"
    }
    args.outputs.labels << {
      x: 640, y: 240, text: "Press A To Continue", size_enum: 3, alignment_enum: 1, r: 255, g: 255, b: 255, font: "fonts/greek-freak.ttf"
    }
    if args.inputs.keyboard.key_down.space || args.inputs.controller_one.key_down.a
      args.gtk.reset
      args.state.scene = :title_screen
    end
    # print a list of hiscores
    dem_funky_scorez = self.high_score_list(args) # make sure they are loaded 
    if dem_funky_scorez.any?  
      y = 540
      x = 140
      args.outputs.labels << {
        x: x,
        y: y + 30,
        text: "No.",
        size_enum: 2,
        r: 255,
        g: 255,
        b: 255,
        a: 255,  
        font: "fonts/greek-freak.ttf"
      }
      args.outputs.labels << {
        x: x + 50,
        y: y + 30,
        text: "Name",
        size_enum: 2,
        r: 255,
        g: 255,
        b: 255,
        a: 255,
        font: "fonts/greek-freak.ttf"
      }
      args.outputs.labels << {
        x: x + 200,
        y: y + 30,
        text: "Score",
        size_enum: 2,
        r: 255,
        g: 255,
        b: 255,
        a: 255,
        font: "fonts/greek-freak.ttf"
      }
      args.outputs.labels << {
        x: x + 310,
        y: y + 30,
        text: "Depth reached",
        size_enum: 2,
        r: 255,
        g: 255,
        b: 255,
        a: 255,
        font: "fonts/greek-freak.ttf"
      }
      args.outputs.labels << {
        x: x + 500,
        y: y + 30,
        text: "Time taken",
        size_enum: 2,
        r: 255,
        g: 255,
        b: 255,
        a: 255,
        font: "fonts/greek-freak.ttf"
      }
      args.outputs.labels << {
        x: x + 650,
        y: y + 30,
        text: "Seed",
        size_enum: 2,
        r: 255,
        g: 255,
        b: 255,
        a: 255,
        font: "fonts/greek-freak.ttf"
      }
      dem_funky_scorez.each_with_index do |entry, index|
        args.outputs.labels << {
          x: x,
          y: y - index * 20,
          text: "#{index + 1}.",
          size_enum: 1,
          r: 255,
          g: 255,
          b: 255,
          a: 255,
          font: "fonts/greek-freak.ttf"
        }
      end
      dem_funky_scorez.each_with_index do |entry, index|
        args.outputs.labels << {
          x: x + 50,
          y: y - index * 20,
          text: "#{entry[:name]}",
          size_enum: 1,
          r: 255,
          g: 255,
          b: 255,
          a: 255,
          font: "fonts/greek-freak.ttf"
        }
      end
      dem_funky_scorez.each_with_index do |entry, index|
        args.outputs.labels << {
          x: x + 200,
          y: y - index * 20,
          text: "#{entry[:score]}",
          size_enum: 1,
          r: 255,
          g: 255,
          b: 255,
          a: 255,
          font: "fonts/greek-freak.ttf"
        }
      end
      dem_funky_scorez.each_with_index do |entry, index|
        args.outputs.labels << {
          x: x+370,
          y: y - index * 20,
          text: "#{entry[:depth]}",
          size_enum: 1,
          r: 255,
          g: 255,
          b: 255,
          a: 255,
          font: "fonts/greek-freak.ttf"
        }
      end
      dem_funky_scorez.each_with_index do |entry, index|
        args.outputs.labels << {
          x: x+550,
          y: y - index * 20,
          text: "#{entry[:time_taken]}",
          size_enum: 1,
          r: 255,
          g: 255,
          b: 255,
          a: 255,
          font: "fonts/greek-freak.ttf"
        }
      end
      dem_funky_scorez.each_with_index do |entry, index|
        args.outputs.labels << {
          x: x+650,
          y: y - index * 20,
          text: "#{entry[:seed]}",
          size_enum: 0,
          r: 255,
          g: 255,
          b: 255,
          a: 255,
          font: "fonts/olivetti.ttf"
        }
      end
    end
  end
end