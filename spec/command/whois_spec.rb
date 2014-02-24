# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__ )
require 'atig/command/whois'
require 'atig/command/info'

include Net::IRC::Constants

describe Atig::Command::Whois do
  include CommandHelper


  def time(t)
    t.utc.strftime("%a %b %d %H:%M:%S +0000 %Y")
  end

  before do
    @command = init Atig::Command::Whois
    @status  = double 'status'
    allow(@status).to receive(:created_at).and_return(time(::Time.at(42)))
    @user    = double "user"
    allow(@user).to receive(:name)       .and_return('name')
    allow(@user).to receive(:id)         .and_return('10')
    allow(@user).to receive(:screen_name).and_return('screen_name')
    allow(@user).to receive(:description).and_return('blah blah')
    allow(@user).to receive(:protected)  .and_return(false)
    allow(@user).to receive(:location)   .and_return('Tokyo, Japan')
    allow(@user).to receive(:created_at) .and_return(time(::Time.at(0)))
    allow(@user).to receive(:status)     .and_return(@status)

    allow(::Time).to receive(:now).and_return(::Time.at(50))
    allow(@followings).to receive(:find_by_screen_name).with('mzp').and_return(@user)
  end

  it "should proide whois command" do
    expect(@command.command_name).to eq(%w(whois))
  end

  it "should show profile" do
    commands = []
    expect(@gateway).to receive(:post){|_,command,_,_,*params|
      commands << command
      case command
      when RPL_WHOISUSER
        expect(params).to eq(['id=10', 'twitter.com', "*", 'name / blah blah'])
      when RPL_WHOISSERVER
        expect(params).to eq(['twitter.com', 'Tokyo, Japan'])
      when RPL_WHOISIDLE
        expect(params).to eq(["8", "0", "seconds idle, signon time"])
      when RPL_ENDOFWHOIS
        expect(params).to eq(["End of WHOIS list"])
      end
    }.at_least(4)
    call '#twitter','whois',%w(mzp)
    expect(commands).to eq([ RPL_WHOISUSER, RPL_WHOISSERVER, RPL_WHOISIDLE, RPL_ENDOFWHOIS])
  end

  it "should append /protect if the user is protected" do
    allow(@user).to receive(:protected).and_return(true)
    commands = []
    expect(@gateway).to receive(:post){|_,command,_,_,*params|
      commands << command
      case command
      when RPL_WHOISUSER
        expect(params).to eq(['id=10', 'twitter.com/protected', "*", 'name / blah blah'])
      when RPL_WHOISSERVER
        expect(params).to eq(['twitter.com/protected', 'Tokyo, Japan'])
      when RPL_WHOISIDLE
        expect(params).to eq(["8", "0", "seconds idle, signon time"])
      when RPL_ENDOFWHOIS
        expect(params).to eq(["End of WHOIS list"])
      end
    }.at_least(4)
    call '#twitter','whois',%w(mzp)
    expect(commands).to eq([ RPL_WHOISUSER, RPL_WHOISSERVER, RPL_WHOISIDLE, RPL_ENDOFWHOIS])
  end
end
