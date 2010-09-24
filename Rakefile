# -*- mode:ruby -*-
require 'rubygems'
#require "shipit"
require 'rake'
require 'rake/clean'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'fileutils'
require 'spec/rake/spectask'

Spec::Rake::SpecTask.new do |t|
  t.libs = t.libs + ["."]
  t.spec_opts = ['--color']
  t.spec_files = FileList['atig/**/*_spec.rb']
end

task :default => [:spec]
task :package => [:clean]
