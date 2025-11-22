class Score

  def self.high_score_list(args)
    args.state.high_scores ||= load_high_scores(args)
  end

  def self.save_high_scores(args)
    lines = args.state.high_scores.map { |s| "#{s.name}|#{s.score}" }
    args.gtk.write_file("high_scores.txt", lines.join("\n"))
  end

  def self.load_high_scores(args)
    data = args.gtk.read_file("high_scores.txt")
    return [] unless data
    scorez = data.split("\n").map do |line|
      name, score = line.split("|")
      { name: name, score: score.to_i }
    end
    args.state.high_scores = scorez
    printf("Loaded high scores: %p\n", scorez)
    printf("Current high scores in state: %p\n", args.state.high_scores)
    return scorez
  end

  def self.calculate(hero, args)
    time_used = args.state.time_elapsed || 0
    score = 0
    if !hero.perished
      score += 1000 # bonus for staying alive
    end
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
      item.atrributes.each do |attr, value|
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
    hero.traumas.each do |trauma|
      if trauma.severity == :minor
        score -= 20
      elsif trauma.severity == :major
        score -= 100
      elsif trauma.severity == :severe
        score -= 250
      elsif trauma.severity == :critical
        score -= 500
      end
    end
    score += hero.max_depth * 100
    score += 5000 if hero.has_item?(:amulet_of_skandor)
    final_score = score / (1 + (time_used / 600.0))
    args.state.final_score = final_score.round
    self.update_high_scores(hero.name, final_score.round, args)
    return final_score
  end

  def self.update_high_scores(name, score, args)
    high_scores = self.high_score_list(args)
    high_scores << { name: name, score: score }
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
      args.state.scene = :title_screen
    end
    # print a list of hiscores
    dem_funky_scorez = self.high_score_list(args) # make sure they are loaded 
    if dem_funky_scorez.any?  
      y = 580
      dem_funky_scorez.each_with_index do |entry, index|
        args.outputs.labels << {
          x: 520,
          y: y - index * 20,
          text: "#{index + 1}. #{entry[:name]} - #{entry[:score]}",
          size_enum: 1,
          r: 255,
          g: 255,
          b: 255,
          a: 255,
          font: "fonts/greek-freak.ttf"
        }
      end
    end
  end
end