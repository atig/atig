# -*- mode:ruby -*-
require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rspec/core/rake_task'
require "bundler/gem_tasks"

CLEAN.include(
  "**/*.db"
)

CLOBBER.include(
  "pkg"
)

RSpec::Core::RakeTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

desc "building document with sphinx"
task :docs do
  build_dir = "docs/_build"
  `sphinx-build -b html -d #{build_dir}/doctrees -D latex_paper_size=a4 docs #{build_dir}/html`
end

task :default => [:spec, :clean]
