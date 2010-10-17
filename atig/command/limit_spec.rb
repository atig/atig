#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/command/limit'
require 'atig/command/command_helper'

describe Atig::Command::Limit do
  include CommandHelper

  before do
    @reset = ::Time.utc(2010,9,25,8,24,12)
    @command = init Atig::Command::Limit
    @api.stub!(:limit).and_return(150)
    @api.stub!(:remain).and_return(148)
    @api.stub!(:reset).and_return(@reset)
  end

  it "should provide limit command" do
    @gateway.names.should == ['rls','limit','limits']
  end

  it "should show limit" do
    @channel.should_receive(:notify).with("148 / 150 (reset at 2010-09-25 08:24:12)")
    call '#twitter', 'limit', []
    @gateway.notified.should == '#twitter'
  end
end
