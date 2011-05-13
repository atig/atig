# -*- mode:ruby -*-
require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'fileutils'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ['--color']
  t.pattern = 'spec/**/*_spec.rb'
end

task :default => [:spec]
task :package => [:clean]
