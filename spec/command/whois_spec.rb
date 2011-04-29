# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__ )
require 'atig/command/whois'
require 'atig/command/command_helper'
require 'atig/command/info'

include Net::IRC::Constants

describe Atig::Command::Whois do
  include CommandHelper


  def time(t)
    t.utc.strftime("%a %b %d %H:%M:%S +0000 %Y")
  end

  before do
    @command = init Atig::Command::Whois
    @status  = stub 'status'
    @status.stub!(:created_at).and_return(time(::Time.at(42)))
    @user    = stub "user"
    @user.stub!(:name)       .and_return('name')
    @user.stub!(:id)         .and_return('10')
    @user.stub!(:screen_name).and_return('screen_name')
    @user.stub!(:description).and_return('blah blah')
    @user.stub!(:protected)  .and_return(false)
    @user.stub!(:location)   .and_return('Tokyo, Japan')
    @user.stub!(:created_at) .and_return(time(::Time.at(0)))
    @user.stub!(:status)     .and_return(@status)

    ::Time.stub!(:now).and_return(::Time.at(50))
    @followings.stub!(:find_by_screen_name).with('mzp').and_return(@user)
  end

  it "should proide whois command" do
    @command.command_name.should == %w(whois)
  end

  it "should show profile" do
    commands = []
    @gateway.should_receive(:post){|_,command,_,_,*params|
      commands << command
      case command
      when RPL_WHOISUSER
        params.should == ['id=10', 'twitter.com', "*", 'name / blah blah']
      when RPL_WHOISSERVER
        params.should == ['twitter.com', 'Tokyo, Japan']
      when RPL_WHOISIDLE
        params.should == ["8", "0", "seconds idle, signon time"]
      when RPL_ENDOFWHOIS
        params.should == ["End of WHOIS list"]
      end
    }.at_least(4)
    call '#twitter','whois',%w(mzp)
    commands.should == [ RPL_WHOISUSER, RPL_WHOISSERVER, RPL_WHOISIDLE, RPL_ENDOFWHOIS]
  end

  it "should append /protect if the user is protected" do
    @user.stub!(:protected).and_return(true)
    commands = []
    @gateway.should_receive(:post){|_,command,_,_,*params|
      commands << command
      case command
      when RPL_WHOISUSER
        params.should == ['id=10', 'twitter.com/protected', "*", 'name / blah blah']
      when RPL_WHOISSERVER
        params.should == ['twitter.com/protected', 'Tokyo, Japan']
      when RPL_WHOISIDLE
        params.should == ["8", "0", "seconds idle, signon time"]
      when RPL_ENDOFWHOIS
        params.should == ["End of WHOIS list"]
      end
    }.at_least(4)
    call '#twitter','whois',%w(mzp)
    commands.should == [ RPL_WHOISUSER, RPL_WHOISSERVER, RPL_WHOISIDLE, RPL_ENDOFWHOIS]
  end
end
