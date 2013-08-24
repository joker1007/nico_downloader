# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nico_downloader/version'

Gem::Specification.new do |spec|
  spec.name          = "nico_downloader"
  spec.version       = NicoDownloader::VERSION
  spec.authors       = ["joker1007"]
  spec.email         = ["kakyoin.hierophant@gmail.com"]
  spec.description   = %q{Download NicoVideos}
  spec.summary       = %q{Download NicoVideos}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "tapp"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "byebug"

  spec.add_dependency "mechanize"
  spec.add_dependency "lumberjack"
  spec.add_dependency "pit"
end
