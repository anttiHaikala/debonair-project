class SoundFX

  @@fx_volume = 0.4

  def self.play_sound(kind, args)
    case kind
    when :walk
      variation = Numeric.rand(1..6)
      args.outputs.audio[:walk] = {
        input: "sounds/walk-#{variation}.mp3",
        gain: @@fx_volume * 0.5
      }
    when :staircase
      args.outputs.audio[:staircase] = {
        input: "sounds/staircase.mp3",
        gain: @@fx_volume
      }
    when :miss
      args.outputs.audio[:miss] = {
        input: "sounds/miss.mp3",
        gain: @@fx_volume
      }
    when :hit
      args.outputs.audio[:punch] = {
        input: "sounds/punch.mp3",
        gain: @@fx_volume
      }
    when :fanfare
      args.outputs.audio[:fanfare] = {
        input: "sounds/fanfare.mp3",
        gain: @@fx_volume
      }
    when :crickets
      args.outputs.audio[:crickets] = {
        input: "sounds/crickets.mp3",
        gain: @@fx_volume
      }
    when :player_died
      args.outputs.audio[:player_died] = {
        input: "sounds/player_died.mp3",
        gain: @@fx_volume
      }
    when :pick_up
      args.outputs.audio[:pick_up] = {
        input: "sounds/pick_up.mp3",
        gain: @@fx_volume
      }
    else
      puts "Sound #{kind} not found!"
    end
  end
  print "SoundFX was played.\n"
end