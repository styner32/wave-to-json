require 'thor'
require 'wave_to_json'

class WaveToJson
  class CLI < Thor
    def initialize(args = [], opts = {}, config = {})
      super(args, opts, config)
    end

    desc 'generate MP3_PATH JSON_PATH', 'generate json file from mp3 file'
    def generate(mp3_path, json_path)
      WaveToJson.new(mp3_path, json_path).generate
    end
  end
end