require './lib/wave_to_json'
require './lib/extract_voice'
require 'json'

mp3_file = ARGV[0]

WaveToJson.new(mp3_file, output_path: 'origin_raw.json').generate
ExtractVoice.new(mp3_file, output_path: 'background_raw.json').generate

original = JSON.parse(File.read('origin_raw.json'))
background = JSON.parse(File.read('background_raw.json'))

diff = []
original.each_with_index { |val, index| result = val - background[index]; diff[index] = result > 0 ? result : 0 }
max = diff.max

results = diff.map { |value| value.to_f / max }
File.open('voice.json', 'w') { |f| f.write(JSON.dump(results)) }
