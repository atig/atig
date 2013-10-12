# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__)
require 'atig/command/user_info'

describe Atig::Command::UserInfo do
  include CommandHelper

  before do
    @command = init Atig::Command::UserInfo
    @status  = stub "status"
    @user    = stub "user"
    @user.stub(:description).and_return('hogehoge')
    @user.stub(:status).and_return(@status)
  end

  it "should show the source via DB" do
    @followings.should_receive(:find_by_screen_name).with('mzp').and_return(@user)
    @channel.
      should_receive(:message).
      with(anything, Net::IRC::Constants::NOTICE).
      and_return{|s,_|
        s.status.text.should == "\x01hogehoge\x01"
      }
    call '#twitter','userinfo',%w(mzp)
  end

  it "should show the source via API" do
    @followings.should_receive(:find_by_screen_name).with('mzp').and_return(nil)
    @api.should_receive(:get).with('users/show',:screen_name=>'mzp').and_return(@user)

    @channel.
      should_receive(:message).
      with(anything, Net::IRC::Constants::NOTICE).
      and_return{|s,_|
        s.status.text.should == "\x01hogehoge\x01"
      }

    call '#twitter','userinfo',%w(mzp)
  end
end
