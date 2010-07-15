#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/spec_helper'
require 'atig/command/refresh'
require 'atig/command/command_helper'
require 'atig/command/info'

describe Atig::Command::Refresh do
  include CommandHelper

  before do
    @command = init Atig::Command::Refresh
  end

  it "should refresh all" do
    @followings.should_receive(:invalidate)
    @lists.should_receive(:invalidate).with(:all)
    @channel.should_receive(:notify).with("refresh followings/lists...")

    call '#twitter','refresh', []
  end
end
