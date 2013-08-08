require 'rubygems'
require 'oj'

class WaveToJson
  PIXEL_PER_SECOND = 1000 / 30.0
  SIZE_OF_SEGMENT = 16

  def initialize(file)
    @file = file
    @target = file.gsub('.mp3', '.raw')
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
    sox_command = [ 'sox', @file, '-t', 'raw', '-r', '44100', '-c', '2', '-b', '16', '-e', 'signed-integer', '-L', '-' ]
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

  def generate(options = {})
    buckets = fill_buckets
    File.open(options[:output_path], 'w') { |file| file.write(Oj.dump(calculate_ratios(*buckets))) }
  end
end