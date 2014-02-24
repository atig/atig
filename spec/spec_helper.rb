# -*- mode:ruby; coding:utf-8 -*-
require 'bundler/setup'
require 'atig/monkey'
require 'command_helper'

ENV['TZ'] = 'UTC'

RSpec::Matchers.define :be_text do |text|
  match do |status|
    expect(status.text).to eq(text)
  end
end

def status(text, opt = {})
  Atig::TwitterStruct.make(opt.merge('text' => text))
end

def user(id, name)
  user = double("User-#{name}")
  allow(user).to receive(:id).and_return(id)
  allow(user).to receive(:screen_name).and_return(name)
  user
end

def entry(user, status, name = 'entry', id = 0)
  entry = double name
  allow(entry).to receive('id').and_return(id)
  allow(entry).to receive('user').and_return(user)
  allow(entry).to receive('status').and_return(status)
  entry
end

require 'coveralls'
Coveralls.wear!
