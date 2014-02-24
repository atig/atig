# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__)
require 'atig/command/user_info'

describe Atig::Command::UserInfo do
  include CommandHelper

  before do
    @command = init Atig::Command::UserInfo
    @status  = double "status"
    @user    = double "user"
    allow(@user).to receive(:description).and_return('hogehoge')
    allow(@user).to receive(:status).and_return(@status)
  end

  it "should show the source via DB" do
    expect(@followings).to receive(:find_by_screen_name).with('mzp').and_return(@user)
    expect(@channel).
      to receive(:message).
      with(anything, Net::IRC::Constants::NOTICE){|s,_|
        expect(s.status.text).to eq("\x01hogehoge\x01")
      }
    call '#twitter','userinfo',%w(mzp)
  end

  it "should show the source via API" do
    expect(@followings).to receive(:find_by_screen_name).with('mzp').and_return(nil)
    expect(@api).to receive(:get).with('users/show',:screen_name=>'mzp').and_return(@user)

    expect(@channel).
      to receive(:message).
      with(anything, Net::IRC::Constants::NOTICE){|s,_|
        expect(s.status.text).to eq("\x01hogehoge\x01")
      }

    call '#twitter','userinfo',%w(mzp)
  end
end
