#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'rubygems'
require 'bundler'

Bundler.setup
Bundler.require :default, :test

$:.insert( 1, File.expand_path( '..', File.dirname(__FILE__) ) )

require 'atig/monkey'

RSpec::Matchers.define :be_text do |text|
  match do |status|
    status.text.should == text
  end
end

def status(text,opt={})
  Atig::TwitterStruct.make(opt.merge('text' => text))
end

def user(id, name)
  user = stub("User-#{name}")
  user.stub!(:id).and_return(id)
  user.stub!(:screen_name).and_return(name)
  user
end

def entry(user,status,name='entry',id=0)
  entry = stub name
  entry.stub!('id').and_return(id)
  entry.stub!('user').and_return(user)
  entry.stub!('status').and_return(status)
  entry
end
