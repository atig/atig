# -*- encoding: utf-8 -*-
require File.expand_path('../lib/atig/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["SHIBATA Hiroshi"]
  gem.email         = ["shibata.hiroshi@gmail.com"]
  gem.description   = %q{Atig.rb is Twitter Irc Gateway.}
  gem.summary       = %q{Atig.rb is forked from cho45's tig.rb. We improve some features of tig.rb.}
  gem.homepage      = "https://github.com/mzp/atig"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "atig"
  gem.require_paths = ["lib"]
  gem.version       = Atig::VERSION

  gem.add_dependency 'sqlite3', ['>= 1.3.2']
  gem.add_dependency 'net-irc', ['>= 0']
  gem.add_dependency 'oauth', ['>= 0']

  gem.add_dependency 'rake', ['>= 0'] unless defined? Rake
  gem.add_dependency 'json', ['>= 0'] unless defined? JSON

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rspec'
end
