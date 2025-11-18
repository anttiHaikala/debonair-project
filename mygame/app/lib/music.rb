class Music

  attr_reader :bpm, :pattern_count, :beat_count, :bar_count
  attr_reader :start_time
  attr_reader :pattern_start_time
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
    @pattern_start_time = now
    @beat_count = -1
    @bar_count = -1
    @pattern_count = -1
    @music_volume = 0.0
    alter_pattern!
  end

  def alter_pattern!
    @pattern = {}
    # add fx on beats 0, 4, 8, 12
    (0...@pattern_length * 4).each do |beat|
      if beat % 4 == 0
        @pattern[:fx] ||= []
        @pattern[:fx] << @samples[:fx].sample if @samples[:fx] && !@samples[:fx].empty?
      else
        @pattern[:fx] ||= []
        @pattern[:fx] << nil
      end
    end
    (0...@pattern_length * 4).each do |beat|
      if beat % 4 == 2
        @pattern[:snare] ||= []
        @pattern[:snare] << @samples[:snare].sample if @samples[:snare] && !@samples[:snare].empty?
      else
        @pattern[:snare] ||= []
        @pattern[:snare] << nil
      end
    end
    # pad on every 8th beat
    (0...@pattern_length * 4).each do |beat|
      if beat % 8 == 0
        @pattern[:pad] ||= []
        @pattern[:pad] << @samples[:pad].sample if @samples[:pad] && !@samples[:pad].empty?
      else
        @pattern[:pad] ||= []
        @pattern[:pad] << nil
      end
    end
  end

  def calc_beat
    (elapsed_pattern_time * 60 / @bpm).floor % (@pattern_length * 4)
  end

  def calc_bars
    (calc_beat / 4).floor % @pattern_length
  end

  def calc_pattern
    (calc_bars / @pattern_length).floor % 8
  end

  def beat_time
    elapsed_time / @bpm
  end

  def elapsed_time
    Time.now - @start_time
  end

  def elapsed_pattern_time
    Time.now - @pattern_start_time
  end

  def pattern_beat_time
    elapsed_pattern_time * 60 / @bpm
  end

  def self.tick(args)
    args.state.music.tick(args) if args.state.music
  end

  def elapsed_time
    Time.now - @start_time
  end

  def tick(args)
    old_beat_count = @beat_count
    new_beat_count = self.calc_beat
    old_bar_count = @bar_count
    new_bar_count = self.calc_bars
    if old_bar_count != new_bar_count
      @bar_count = new_bar_count
      printf "Music: New bar started: #{@bar_count}\n"
    end
    #printf "Music tick... elapsed time = #{self.elapsed_time} # pattern time: #{elapsed_pattern_time} old beat #{old_beat} / new beat #{new_beat}\n"
    old_pattern_count = @pattern_count
    new_pattern_count = self.calc_pattern
    if old_pattern_count != new_pattern_count  
      @pattern_start_time = Time.now
      alter_pattern!
      @pattern_count = new_pattern_count
      printf "Music: New pattern started.\n"
    end
    if old_beat_count != new_beat_count
      @beat_count = new_beat_count
      printf "Music: Pattern: #{@pattern_count} Bar: #{@bar_count} Beat: #{@beat_count}\n"
      play_beat(args)
    end
  end

  def play_beat(args)
      # play pattern sounds for this beat from all banks
      if @pattern
        @pattern.each do |kind, beats|
          if beats && beats[@beat_count]
            sample_file = beats[@beat_count]
            printf "Playing sample: %s\n" % sample_file
            sample_path = "sounds/music/#{kind}/" + sample_file
            args.outputs.audio[kind] = {
              input: sample_path,
              gain: @music_volume || 0.5
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

