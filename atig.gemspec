# -*- encoding: utf-8 -*-
require File.expand_path('../lib/atig/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "atig"
  spec.version       = Atig::VERSION
  spec.authors       = ["MIZUNO Hiroki", "SHIBATA Hiroshi", ]
  spec.email         = ["mzp@ocaml.jp", "shibata.hiroshi@gmail.com"]

  spec.summary       = %q{Atig.rb is forked from cho45's tig.rb. We improve some features of tig.rb.}
  spec.description   = %q{Atig.rb is Twitter Irc Gateway.}
  spec.homepage      = "https://github.com/atig/atig"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.required_ruby_version = Gem::Requirement.new(">= 1.9.3")

  spec.add_dependency 'sqlite3', '>= 1.3.2'
  spec.add_dependency 'net-irc'
  spec.add_dependency 'oauth'
  spec.add_dependency 'twitter-text'
  spec.add_dependency 'addressable'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'coveralls'
end
