#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require File.expand_path( '../spec_helper', File.dirname(__FILE__) )
require 'atig/command/location'
require 'atig/command/command_helper'

describe Atig::Command::Location do
  include CommandHelper

  before do
    @command = init Atig::Command::Location
  end

  it "should update location" do
    @api.should_receive(:post).with('account/update_profile',:location=>'some place')
    @channel.should_receive(:notify).with("You are in some place now.")
    call '#twitter','location',%w(some place)
  end

  it "should reset location" do
    @api.should_receive(:post).with('account/update_profile',:location=>'')
    @channel.should_receive(:notify).with("You are nowhere now.")
    call '#twitter','location',%w()
  end
end
