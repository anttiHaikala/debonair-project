class SoundFX

  @@fx_volume = 0.4

  def self.play(kind, args)
    self.play_sound(kind, args)
  end

  def self.play_sound(kind, args, volume = 1.0)
    if args.outputs.audio[kind]
      # sound is already playing, do not overlap
      return
    end
    final_volume = @@fx_volume * volume
    printf "Playing sound: %s at volume %.2f\n" % [kind.to_s, final_volume]
    args.outputs.audio[kind] = {
        input: "sounds/#{kind}.mp3",
        gain: final_volume
    }
  end

  def self.play_sound_xy(kind, x, y, args)
    # adjust volume based on distance
    # assume hero is listener
    hero = args.state.hero
    level = Utils.level(args)
    hero_x = hero.x 
    hero_y = hero.y 
    distance = Math.sqrt((hero_x - x) ** 2 + (hero_y - y) ** 2)    
    max_hear_distance = 12
    printf "SoundFX: distance to sound source: %.2f\n" % [distance]
    if distance > max_hear_distance
      return
    end
    volume = 1.0 - (distance.to_f / max_hear_distance.to_f)
    printf "SoundFX: playing sound %s at volume %.2f\n" % [kind.to_s, volume]
    self.play_sound(kind, args, volume)
  end

  def self.play_walking_sound(npc, args)
    sound_name = 'walks/' + npc.species.to_s
    self.play_sound_xy(sound_name, npc.x, npc.y, args)
  end
end
