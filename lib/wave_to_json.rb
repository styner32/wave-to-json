require 'rubygems'
require 'oj'

class WaveToJson
  OPTION_FOR_LEFT = %w(remix 1 1)
  OPTION_FOR_RIGHT = %w(remix 2 2)
  PIXEL_PER_SECOND = 1000 / 30.0
  SIZE_OF_SEGMENT = 16

  def initialize(file, options = {})
    @file = file
    @command_for_rawfile = [ 'sox', file, '-t', 'raw', '-r', '44100', '-c', '1', '-b', '16', '-e', 'signed-integer', '-L', '-' ]
    @output_path = options[:output_path]
    if options[:side]
      if options[:side] == :right
        @command_for_rawfile.concat OPTION_FOR_RIGHT
      elsif options[:side] == :left
        @command_for_rawfile.concat OPTION_FOR_LEFT
      end
    end
  end

  def fill_buckets
    mins = []
    maxs = []

    content = generate_raw_file
    contents = content.unpack('l*')
    bucket_size = (contents.length.to_f / width)
    contents.each_with_index do |value, i|
      index = (i / bucket_size).to_i
      next if index >= (width - 1)

      mins[index] = value if mins[index].nil? || value < mins[index]
      maxs[index] = value if maxs[index].nil? || value > maxs[index]
    end

    [mins, maxs]
  end

  def generate_raw_file
    raw_value=nil
    sox_command = @command_for_rawfile
    IO.popen('-') do |p|
      if p.nil?
        $stderr.close
        exec *sox_command
      end
      raw_value = p.read
    end
    if raw_value.size == 0
      raise Exception.new("sox returned no data, command was\n> #{sox_command.join(' ')}")
    end

    raw_value
  end

  def sox_get_length
    sox_command = ['soxi', '-D', @file]
    length = nil
    IO.popen('-') do |p|
      if p.nil?
        $stderr.close
        exec *sox_command
      end
      length = p.read
    end

    length.to_f * 1000
  end

  def width
    @width ||= (sox_get_length / PIXEL_PER_SECOND).round
  end

  def calculate_ratios(mins, maxs)
    max = 0
    results = (0..mins.length-1).map do |i|
      height = maxs[i] - mins[i]
      max = height > max ? height : max
      height
    end

    results.map do |result|
      (result / max.to_f).round(6)
    end
  end

  def generate
    buckets = fill_buckets
    File.open(@output_path, 'w') { |file| file.write(Oj.dump(calculate_ratios(*buckets))) }
  end
end
