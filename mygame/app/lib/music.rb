class Music

  attr_reader :bpm, :pattern_count, :beat_count, :bar_count
  attr_reader :start_time
  attr_reader :pattern_length

  def self.setup(args)
    args.state.music = Music.new
    args.state.music.start
  end

  def initialize
    printf "Initializing music system...\n"
    @samples = {}
    scan_samples
    @bpm = 80
    @pattern_length = 8 # bars
  end

  def start
    printf "Starting music system...\n"
    now = Time.now
    @start_time = now
    @beat_count = nil 
    @bar_count = nil
    @pattern_count = nil
    @music_volume = 0.3
    alter_pattern!
  end

  def alter_pattern!
    @pattern ||= {}
    @pattern[:notes] ||= {}
    printf "Altering music pattern...\n"
    # fx track
    if Numeric.rand(0.0..1.0) < 0.2
      (0...@pattern_length * 4).each do |beat|
        if beat % 4 == 0
          @pattern[:fx] ||= []
          @pattern[:fx] << @samples[:fx].sample if @samples[:fx] && !@samples[:fx].empty?
        else
          @pattern[:fx] ||= []
          @pattern[:fx] << nil
        end
      end
    end
    # strings track
    if Numeric.rand(0.0..1.0) < 0.4
      string_sample = @samples[:strings].sample
      (0...@pattern_length * 4).each do |beat|
        if beat % 8 == 0
          @pattern[:notes][:strings] ||= []
          @pattern[:strings] ||= []
          @pattern[:strings] << string_sample if string_sample
          @pattern[:notes][:strings] << 0
        elsif beat % 8 == 4
          @pattern[:strings] ||= []
          @pattern[:strings] << string_sample if string_sample
          @pattern[:notes][:strings] << 3
        else
          @pattern[:strings] ||= []
          @pattern[:strings] << nil
          @pattern[:notes][:strings] << nil
        end
      end
    end
    # drumtrax
    if Numeric.rand(0.0..1.0) < 0.2
      (0...@pattern_length * 4).each do |beat|
        kick_sample = @samples[:kick].sample
        snare_sample = @samples[:snare].sample
        hihat_sample = @samples[:hihat].sample
        @pattern[:hihat] ||= []
        @pattern[:hihat] << hihat_sample if hihat_sample
        if beat % 4 == 2
          @pattern[:snare] ||= []
          @pattern[:snare] << snare_sample if snare_sample
        else
          @pattern[:snare] ||= []
          @pattern[:snare] << nil
        end
        if beat % 4 == 0
          @pattern[:kick] ||= []
          @pattern[:kick] << kick_sample if kick_sample
        else
          @pattern[:kick] ||= []
          @pattern[:kick] << nil
        end
      end
    end
    # pad
    if Numeric.rand(0.0..1.0) < 0.5
      @pattern[:pad] = nil
      # pad on every 8th beat
      the_sample = @samples[:pad].sample
      (0...@pattern_length * 4).each do |beat|
        if beat % 8 == 0
          @pattern[:pad] ||= []
          @pattern[:pad] << the_sample if @samples[:pad] && !@samples[:pad].empty?
          @pattern[:notes][:pad] ||= []
          @pattern[:notes][:pad] << [0,5,7,10].sample
        elsif beat % 8 == 4
          @pattern[:pad] ||= []
          @pattern[:pad] << the_sample if @samples[:pad] && !@samples[:pad].empty?
          @pattern[:notes][:pad] ||= []
          @pattern[:notes][:pad] << [0,5,7,10].sample
        else
          @pattern[:pad] ||= []
          @pattern[:pad] << nil
        end
      end
    end
    if Numeric.rand(0.0..1.0) < 0.3
      # perc can be pretty random lol
      primary_sample = @samples[:perc].sample
      secondary_sample = @samples[:perc].sample
      interval = [1,2,3,4,6].sample
      (0...@pattern_length * 4).each do |beat|
        the_sample = Numeric.rand(0.0..1.0) < 0.7 ? primary_sample : secondary_sample
        if beat % interval == 0
          @pattern[:perc] ||= []
          @pattern[:perc] << the_sample if @samples[:perc] && !@samples[:perc].empty?
        else
          @pattern[:pad] ||= []
          @pattern[:pad] << nil
        end
      end
    end
  end

  def calc_beat
    (elapsed_time * 60 / @bpm).floor % (@pattern_length * 4)
  end

  def calc_bars
    (calc_beat / 4).floor % @pattern_length
  end

  def calc_pattern
    (elapsed_time * 60 / @bpm / 4 / @pattern_length).floor
  end

  def elapsed_time
    Time.now - @start_time
  end

  def self.tick(args)
    args.state.music.tick(args) if args.state.music
  end

  def elapsed_time
    Time.now - @start_time
  end

  def tick(args)
    old_bar_count = @bar_count
    new_bar_count = self.calc_bars
    if old_bar_count != new_bar_count
      @bar_count = new_bar_count
    end
    #printf "Music tick... elapsed time = #{self.elapsed_time} # pattern time: #{elapsed_pattern_time} old beat #{old_beat} / new beat #{new_beat}\n"
    old_pattern_count = @pattern_count
    new_pattern_count = self.calc_pattern
    if old_pattern_count != new_pattern_count  
      @pattern_count = new_pattern_count
      alter_pattern!
    end
    old_beat_count = @beat_count
    new_beat_count = self.calc_beat
    if old_beat_count != new_beat_count
      @beat_count = new_beat_count
      printf "Pattern: #{@pattern_count} Bar: #{@bar_count} Beat: #{@beat_count}\n"
      play_beat(args)
    end
  end

  def play_beat(args)
      # play pattern sounds for this beat from all banks
      if @pattern
        @pattern.each do |kind, beats|
          if beats && beats[@beat_count]
            # do we have a note(pitch) info also?
            if @pattern[:notes] && @pattern[:notes][kind] && @pattern[:notes][kind][@beat_count]
              pitch = @pattern[:notes][kind][@beat_count]
              numeric_pitch = (pitch - 1.0)/12.0 + 1.0
              printf "Playing sample: %s with semitone pitch %s - numeric pitch: %s\n" % [kind.to_s, pitch.to_s, numeric_pitch.to_s]
            end
            sample_file = beats[@beat_count]
            #printf "Playing sample: %s\n" % sample_file
            sample_path = "sounds/music/#{kind}/" + sample_file
            args.outputs.audio[kind] = {
              input: sample_path,
              gain: @music_volume || 0.5,
              pitch: numeric_pitch || 1.0
            }
          end
        end
      end
  end

  def scan_samples
    printf "Scanning music samples...\n"
    # iterate through directory structure and find music samples
    # Dir.glob not working
    @samples = {}
    path = "sounds/music/"
    $gtk.list_files(path).each do |subdirectory|
      next if subdirectory == ".DS_Store"
      kind = subdirectory.split("/").last.to_sym
      @samples[kind.to_sym] = []
      # Check if it's a directory by trying to list its contents
      subdir_path = path + subdirectory + "/"
      sub_files = $gtk.list_files(subdir_path) rescue nil
      next unless sub_files
      if sub_files
        # It's a directory, recurse into it
        $gtk.list_files(subdir_path).each do |file|
          next if file == ".DS_Store"
          if file.end_with?(".mp3")
            @samples[kind.to_sym] << file
          end
        end
      end
    end
    @samples.each do |kind, files|
      printf "Samples for kind %s: %s\n" % [kind, files.size.to_s]
    end
  end
end

