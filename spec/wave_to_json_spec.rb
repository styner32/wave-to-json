require 'spec_helper'

describe WaveToJson do
  let(:esp) { 0.001 }

  describe '.generate' do
    let(:mp3_path) { File.join(File.dirname(__FILE__), 'fixtures', 'test.mp3') }
    let(:expected_output) { File.read(File.join(File.dirname(__FILE__), 'fixtures', 'test.json')) }
    let(:output_path) { File.join(File.dirname(__FILE__), 'test_result', 'test.json') }
    let(:output) { File.read(output_path) }
    let(:options) { { } }

    subject { WaveToJson.new(mp3_path, output_path, options).generate }

    after { FileUtils.rm(output_path) }

    it 'generates waveform in json format' do
      subject
      output_in_json = Oj.load(output)
      expected_output_in_json = Oj.load(expected_output)

      output_in_json.each_with_index do |value, index|
        expected_value = expected_output_in_json[index]
        value.should be_within(esp).of(expected_value)
      end
    end
  end
end
