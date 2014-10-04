class WaveToJson
  class Audio
    MAX_VALUE = 2**16
    MIN_VALUE = -(2**16)

    def initialize(audio_path)
      @path = audio_path
    end

    def duration
      return @duration if @duration
      @duration = ShellCommand.new(['soxi', '-D', @path]).run_and_return_output_if_success.to_f
    end

    def number_of_channels
      return @number_of_channels if @number_of_channels
      @number_of_channels = ShellCommand.new(['soxi', '-c', @path]).run_and_return_output_if_success.to_i
    end

    def raw_data(options = {})
      command = [ 'sox', @path, '-t', 'raw', '-r', '44100', '-c', '1', '-e', 'signed-integer', '-L', '-' ]
      if options[:channel] == :left
        command.concat(%w(remix 1 1))
      elsif options[:channel] == :right
        command.concat(%w(remix 2 2))
      end

      ShellCommand.new(command).run_and_return_output_if_success.unpack('l*')
    end

    def generate_raw_file(raw_file_path, options={})
      command = [ 'sox', @path, '-t', 'raw', '-r', '44100', '-c', '1', '-e', 'signed-integer', '-L', raw_file_path ]
      if options[:channel] == :left
        command.concat(%w(remix 1 1))
      elsif options[:channel] == :right
        command.concat(%w(remix 2 2))
      end

      ShellCommand.new(command).execute
    end
  end
end
