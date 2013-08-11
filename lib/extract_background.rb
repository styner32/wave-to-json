require 'rubygems'
require 'oj'

class ExtractVoice
  PIXEL_PER_SECOND = 1000 / 30.0
  SIZE_OF_SEGMENT = 16

  def initialize(file, options = {})
    @file = file
    @command_for_mono = [ 'sox', file, '-t', 'raw', '-r', '44100', '-c', '1', '-b', '16', '-e', 'signed-integer', '-L', '-' ]
    @command_for_left = [ 'sox', file, '-t', 'raw', '-r', '44100', '-c', '1', '-b', '16', '-e', 'signed-integer', '-L', '-', 'remix', '1', '1' ]
    @command_for_right = [ 'sox', file, '-t', 'raw', '-r', '44100', '-c', '1', '-b', '16', '-e', 'signed-integer', '-L', '-', 'remix', '2', '2' ]
    @command_for_length = ['soxi', '-D', file]
    @output_path = options[:output_path]
  end

  def fill_buckets
    mins = []
    maxs = []

    left_content = run_command @command_for_left
    right_content = run_command @command_for_right

    left_contents = left_content.unpack('l*')
    right_contents = right_content.unpack('l*')

    bucket_size = (left_contents.length.to_f / width)
    left_contents.each_with_index do |value, i|
      index = (i / bucket_size).to_i
      next if index >= (width - 1)

      diff_value = (value - right_contents[i])

      mins[index] = diff_value if mins[index].nil? || diff_value < mins[index]
      maxs[index] = diff_value if maxs[index].nil? || diff_value > maxs[index]
    end

    [mins, maxs]
  end

  def width
    @width ||= ((run_command(@command_for_length).to_f*1000) / PIXEL_PER_SECOND).round
  end

  def calculate_ratios(mins, maxs)
    max = 0
    results = (0..mins.length-1).map do |i|
      height = maxs[i] - mins[i]
      max = height > max ? height : max
      height
    end

    #results.map do |result|
    #  (result / max.to_f).round(6)
    #end
    results
  end

  def generate
    buckets = fill_buckets
    File.open(@output_path, 'w') { |file| file.write(Oj.dump(calculate_ratios(*buckets))) }
  end

  private
  def run_command(command)
    result = nil
    IO.popen('-') do |p|
      if p.nil?
        $stderr.close
        exec *command
      end
      result = p.read
    end

    if result.size == 0
      raise Exception.new("An error has occurred. command was\n> #{command.join(' ')}")
    end

    result
  end
end
