#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/spec_helper'
require 'atig/command/time'
require 'atig/command/command_helper'

describe Atig::Command::Time do
  include CommandHelper

  def user(offset, tz)
    u = mock "user-#{offset}"
    u.stub!(:utc_offset).and_return(offset)
    u.stub!(:time_zone).and_return(tz)
    u
  end

  before do
    @command = init Atig::Command::Time
    @user    = user(61*60+1,'Tokyo')
  end

  it "should provide time command" do
    @gateway.names.should == ['time']
  end

  it "should show offset time on DB" do
    ::Time.should_receive(:now).and_return(Time.at(0))
    @followings.should_receive(:find_by_screen_name).with('mzp').and_return(@user)
    @channel.
      should_receive(:message).
      with(anything, Net::IRC::Constants::NOTICE).
      and_return{|s,_|
        s.status.text.should == "\x01TIME :1970-01-01T01:01:01+01:01 (Tokyo)\x01"
      }
    call '#twitter', 'time', ['mzp']
    @gateway.notified.should == '#twitter'
  end

  it "should show offset time via API" do
    ::Time.should_receive(:now).and_return(Time.at(0))
    @followings.should_receive(:find_by_screen_name).with('mzp').and_return(nil)
    @api.should_receive(:get).with('users/show', :screen_name=>'mzp').and_return(@user)
    @channel.
      should_receive(:message).
      with(anything, Net::IRC::Constants::NOTICE).
      and_return{|s,_|
        s.status.text.should == "\x01TIME :1970-01-01T01:01:01+01:01 (Tokyo)\x01"
      }
    call '#twitter', 'time', ['mzp']
    @gateway.notified.should == '#twitter'
  end
end
