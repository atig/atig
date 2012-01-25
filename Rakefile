# -*- mode:ruby -*-
require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rspec/core/rake_task'
require "bundler/gem_tasks"

CLEAN.include(
  "**/*.db"
)

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ['--color']
  t.pattern = 'spec/**/*_spec.rb'
end

task :default => [:spec, :clean]
