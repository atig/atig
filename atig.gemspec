# -*- encoding: utf-8 -*-
require File.expand_path('../lib/atig/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "atig"
  gem.version       = Atig::VERSION
  gem.authors       = ["MIZUNO Hiroki", "SHIBATA Hiroshi", ]
  gem.email         = ["mzp@ocaml.jp", "shibata.hiroshi@gmail.com"]

  gem.summary       = %q{Atig.rb is forked from cho45's tig.rb. We improve some features of tig.rb.}
  gem.description   = %q{Atig.rb is Twitter Irc Gateway.}
  gem.homepage      = "https://github.com/atig/atig"

  gem.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  gem.bindir        = "exe"
  gem.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  gem.require_paths = ["lib"]
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.required_ruby_version = Gem::Requirement.new(">= 1.9.3")

  gem.add_dependency 'sqlite3', ['>= 1.3.2']
  gem.add_dependency 'net-irc', ['>= 0']
  gem.add_dependency 'oauth', ['>= 0']
  gem.add_dependency 'twitter-text', ['~> 1.7.0']

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'coveralls'
end
