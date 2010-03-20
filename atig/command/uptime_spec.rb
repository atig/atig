#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/command/uptime'
require 'atig/command/command_helper'

describe Atig::Command::Uptime do
  include CommandHelper

  before do
    ::Time.should_receive(:now).and_return(::Time.at(0))
    @command = init Atig::Command::Uptime
  end

  it "should register uptime command" do
    @gateway.names.should == ['uptime']
  end

  it "should return mm:ss(min)" do
    ::Time.should_receive(:now).and_return(::Time.at(0))
    @channel.should_receive(:notify).with("00:00")
    call '#twitter', 'uptime', []

    @gateway.notified.should == '#twitter'
  end

  it "should return mm:ss(max)" do
    ::Time.should_receive(:now).and_return(::Time.at(60*60-1))
    @channel.should_receive(:notify).with("59:59")
    call '#twitter', 'uptime', []

    @gateway.notified.should == '#twitter'
  end

  it "should return hh:mm:ss(min)" do
    ::Time.should_receive(:now).and_return(::Time.at(60*60))
    @channel.should_receive(:notify).with("01:00:00")
    call '#twitter', 'uptime', []
    @gateway.notified.should == '#twitter'
  end

  it "should return hh:mm:ss(max)" do
    ::Time.should_receive(:now).and_return(::Time.at(24*60*60-1))
    @channel.should_receive(:notify).with("23:59:59")
    call '#twitter', 'uptime', []
    @gateway.notified.should == '#twitter'
  end

  it "should return dd days hh:mm:ss" do
    ::Time.should_receive(:now).and_return(::Time.at(24*60*60))
    @channel.should_receive(:notify).with("1 days 00:00")
    call '#twitter', 'uptime', []
    @gateway.notified.should == '#twitter'
  end
end
