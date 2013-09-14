require 'oj'
require 'wave_to_json/version'
require 'shell_command'
require 'audio'

class WaveToJson
  DEFAULT_PIXEL_PER_SECOND = 1000 / 30.0

  def initialize(source, destination, options = {})
    @filename = source
    @output_path = destination
    @pixel_per_second = options.fetch(:pixel_per_second, DEFAULT_PIXEL_PER_SECOND)
    @audio = Audio.new(@filename)
  end

  def raw_values
    min_values = []
    max_values = []

    contents = @audio.raw_data
    segment_size = (contents.length.to_f / width).to_i
    current_index = 0
    min = Audio::MAX_VALUE
    max = Audio::MIN_VALUE

    contents.each do |value|
      if current_index == segment_size
        max_values.push(max)
        min_values.push(min)

        current_index = 0
        min = Audio::MAX_VALUE
        max = Audio::MIN_VALUE
      else
        min = value < min ? value : min
        max = value > max ? value : max
        current_index+=1
      end
    end

    if current_index != 0
      max_values.push(max)
      min_values.push(min)
    end

    [min_values, max_values]
  end

  def width
    duration_in_millisecond = @audio.duration * 1000
    @width ||= ( duration_in_millisecond/ @pixel_per_second).round
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
