# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__ )
require 'atig/command/version'

describe Atig::Command::Version do
  include CommandHelper

  before do
    @command = init Atig::Command::Version
    @status  = double "status"
    allow(@status).to receive(:source).and_return('<a href="http://echofon.com/" rel="nofollow">Echofon</a>')
    @user    = double "user"
    allow(@user).to receive(:status).and_return(@status)
  end

  it "should provide version command" do
    expect(@gateway.names).to eq(['version'])
  end

  it "should show the source via DB" do
    expect(@statuses).
      to receive(:find_by_screen_name).
      with('mzp',:limit => 1).
      and_return([ entry(@user,@status) ])
    expect(@channel).
      to receive(:message).
      with(anything, Net::IRC::Constants::NOTICE){|s,_|
        expect(s.status.text).to eq("\x01Echofon <http://echofon.com/>\x01")
      }
    call '#twitter','version',%w(mzp)
  end

  it "should show the source of web" do
    status  = double "status"
    allow(status).to receive(:source).and_return('web')
    expect(@statuses).
      to receive(:find_by_screen_name).
      with('mzp',:limit => 1).
      and_return([ entry(@user,status) ])
    expect(@channel).
      to receive(:message).
      with(anything, Net::IRC::Constants::NOTICE){|s,_|
        expect(s.status.text).to eq("\x01web\x01")
      }
    call '#twitter','version',%w(mzp)
  end

  it "should show the source via API" do
    allow(@statuses).to receive(:find_by_screen_name).and_return(@status)
    expect(@statuses).to receive(:find_by_screen_name).with('mzp',:limit => 1).and_return(nil)
    expect(@statuses).to receive(:add).with(status: @status, user: @user, source: :version)
    expect(@api).to receive(:get).with('users/show',:screen_name=>'mzp').and_return(@user)

    expect(@channel).
      to receive(:message).
      with(anything, Net::IRC::Constants::NOTICE){|s,_|
        expect(s.status.text).to eq("\x01Echofon <http://echofon.com/>\x01")
      }

    call '#twitter','version',%w(mzp)
  end
end
