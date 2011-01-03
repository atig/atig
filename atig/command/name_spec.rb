#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require File.expand_path( '../spec_helper', File.dirname(__FILE__) )
require 'atig/command/name'
require 'atig/command/command_helper'

describe Atig::Command::Name do
  include CommandHelper

  before do
    @command = init Atig::Command::Name
  end

  it "should update name" do
    @api.should_receive(:post).with('account/update_profile',:name=>'mzp')
    @channel.should_receive(:notify).with("You are named mzp.")
    call '#twitter', 'name', %w(mzp)
  end
end
