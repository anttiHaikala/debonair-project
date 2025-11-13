class SoundFX

  @@fx_volume = 0.4

  def self.play_sound(kind, args)
    printf "Playing sound: %s\n" % [kind.to_s]
    args.outputs.audio[kind] = {
        input: "sounds/#{kind}.mp3",
        gain: @@fx_volume
    }
  end
  print "SoundFX was played.\n"
end