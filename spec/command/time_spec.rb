# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__ )
require 'atig/command/time'

describe Atig::Command::Time do
  include CommandHelper

  def user(offset, tz)
    u = double "user-#{offset}"
    allow(u).to receive(:utc_offset).and_return(offset)
    allow(u).to receive(:time_zone).and_return(tz)
    u
  end

  before do
    @command = init Atig::Command::Time
    @user    = user(61*60+1,'Tokyo')
  end

  it "should provide time command" do
    expect(@gateway.names).to eq(['time'])
  end

  it "should show offset time on DB" do
    expect(::Time).to receive(:now).and_return(Time.at(0))
    expect(@followings).to receive(:find_by_screen_name).with('mzp').and_return(@user)
    expect(@channel).
      to receive(:message).
      with(anything, Net::IRC::Constants::NOTICE){|s,_|
        expect(s.status.text).to eq("\x01TIME :1970-01-01T01:01:01+01:01 (Tokyo)\x01")
      }
    call '#twitter', 'time', ['mzp']
    expect(@gateway.notified).to eq('#twitter')
  end

  it "should show offset time via API" do
    expect(::Time).to receive(:now).and_return(Time.at(0))
    expect(@followings).to receive(:find_by_screen_name).with('mzp').and_return(nil)
    expect(@api).to receive(:get).with('users/show', screen_name:'mzp').and_return(@user)
    expect(@channel).
      to receive(:message).
      with(anything, Net::IRC::Constants::NOTICE){|s,_|
        expect(s.status.text).to eq("\x01TIME :1970-01-01T01:01:01+01:01 (Tokyo)\x01")
      }
    call '#twitter', 'time', ['mzp']
    expect(@gateway.notified).to eq('#twitter')
  end
end
