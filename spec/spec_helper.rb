# -*- mode:ruby; coding:utf-8 -*-
require 'rubygems'
require 'bundler'

Bundler.setup
Bundler.require :default, :test

require 'atig/monkey'
require 'command_helper'

RSpec::Matchers.define :be_text do |text|
  match do |status|
    status.text.should == text
  end
end

def status(text, opt = {})
  Atig::TwitterStruct.make(opt.merge('text' => text))
end

def user(id, name)
  user = double("User-#{name}")
  user.stub(:id).and_return(id)
  user.stub(:screen_name).and_return(name)
  user
end

def entry(user, status, name = 'entry', id = 0)
  entry = double name
  entry.stub('id').and_return(id)
  entry.stub('user').and_return(user)
  entry.stub('status').and_return(status)
  entry
end

require 'coveralls'
Coveralls.wear!
