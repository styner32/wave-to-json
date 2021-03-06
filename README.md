wave-to-json
=============
generate a waveform in json format
[![Build Status](https://travis-ci.org/styner32/wave-to-json.svg?branch=master)](https://travis-ci.org/styner32/wave-to-json)

Installation
============

wave-to-json require `sox`.

install it via `brew` or `apt`
```sh
brew install sox
```
or
```sh
sudo apt-get install sox libsox-fmt-mp3
```

Usage by examples
-----------------

convert mp3 file to json format

```ruby
WaveToJson.new(SOURCE, DESTINATION, OPTIONS).generate
```

* Both channels

```ruby
WaveToJson.new('test.mp3', 'test.json').generate
```
* Left channel

Generate from left channel
```ruby
WaveToJson.new('test.mp3', 'test.json', channel: :left).generate
```

* Right channel

Generate json format from right channel
```ruby
WaveToJson.new('test.mp3', 'test.json', channel: :right).generate
```

CLI Usage
-----------------
```sh
  $ wave_to_json generate song.mp3 waveform.json
```

