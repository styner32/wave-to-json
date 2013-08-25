# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "wave_to_json/version"

Gem::Specification.new do |s|
  s.name        = "wave_to_json"
  s.version     = WaveToJson::VERSION
  s.authors     = ["Sunjin Lee"]
  s.email       = ["styner32@gmail.com"]
  s.homepage    = "https://github.com/styner32/wave-to-json"
  s.summary     = %q{Convert audio file in json format}
  s.description = %q{Convert audio file in json format}
  s.license       = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.require_paths = ["lib"]
  s.required_ruby_version = '>= 2.0.0'

  s.add_runtime_dependency     "oj", "~> 2.0"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
end
