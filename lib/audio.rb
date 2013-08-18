class Audio
  def initialize(audio_path)
    @path = audio_path
  end

  def duration
    return @duration if @duration
    @duration = RunCommand.new(['soxi', '-D', @path]).run_and_return_output_if_success.to_f
  end

  def number_of_channels
    return @number_of_channels if @number_of_channels
    @number_of_channels = RunCommand.new(['soxi', '-c', @path]).run_and_return_output_if_success.to_i
  end

  def raw_data(options = {})
    command = [ 'sox', @path, '-t', 'raw', '-r', '44100', '-c', '1', '-e', 'signed-integer', '-L', '-' ]
    if options[:channel] == :left
      command.concat(%w(remix 1 1))
    elsif options[:channel] == :right
      command.concat(%w(remix 2 2))
    end

    RunCommand.new(command).run_and_return_output_if_success.unpack('l*')
  end
end
