class SoundFX
  def self.play_sound(args, kind)
    case kind
    when :walk
      variation = Numeric.rand(1..6)
      args.outputs.audio[:walk] = {
        input: "sounds/walk-#{variation}.mp3",
        volume: 0.5
      }
    when :staircase
      args.outputs.audio[:staircase] = {
        input: "sounds/staircase.mp3",
        volume: 0.5
      }
    else
      puts "Sound #{kind} not found!"
    end
  end
end