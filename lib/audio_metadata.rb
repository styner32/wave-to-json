class AudioMetadata
  def initialize(audio_path)
    @path = audio_path
  end

  def fetch_data
    run_command(['soxi', '-D', @path])
  end

  private
  def run_command(*commend)
    length = nil
    IO.popen('-') do |p|
      if p.nil?
        $stderr.close
        exec *commend
      end
      length = p.read
    end

    length.to_f * 1000
  end
end
