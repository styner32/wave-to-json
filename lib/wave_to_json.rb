require 'rubygems'
require 'oj'
require 'run_command'
require 'audio'

class WaveToJson
  PIXEL_PER_SECOND = 1000 / 30.0
  SIZE_OF_SEGMENT = 16

  def initialize(filename, options = {})
    @filename = filename
    @output_path = options[:output_path]
    @audio = Audio.new(filename)
  end

  def raw_values
    min_values = []
    max_values = []

    contents = @audio.raw_data
    bucket_size = (contents.length.to_f / width)
    contents.each_with_index do |value, i|
      index = (i / bucket_size).to_i
      next if index >= (width - 1)

      min_values[index] = value if min_values[index].nil? || value < min_values[index]
      max_values[index] = value if max_values[index].nil? || value > max_values[index]
    end

    [min_values, max_values]
  end

  def width
    duration_in_millisecond = @audio.duration * 1000
    @width ||= ( duration_in_millisecond/ PIXEL_PER_SECOND).round
  end

  def calculate_ratios(mins, maxs)
    max = 0
    results = (0..mins.length-1).map do |i|
      height = maxs[i] - mins[i]
      max = height > max ? height : max
      height
    end

    results.map { |result| (result / max.to_f).round(6) }
  end

  def generate
    File.open(@output_path, 'w') do |file|
      values = raw_values
      converted_values = calculate_ratios(*values)
      file.write(Oj.dump(converted_values))
    end
  end
end
