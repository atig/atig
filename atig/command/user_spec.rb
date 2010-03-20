#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/spec_helper'
require 'atig/command/user'
require 'atig/command/command_helper'

describe Atig::Command::User do
  include CommandHelper
  before do
    @command = init Atig::Command::User
  end

  it "should have '/me status' name" do
    @gateway.names.should == ['user', 'u']
  end

  it "should" do
    foo = entry user(1,'mzp'),status('foo')
    bar = entry user(1,'mzp'),status('bar')
    baz = entry user(1,'mzp'),status('baz')
    @api.
      should_receive(:get).
      with('statuses/user_timeline',:count=>20,:screen_name=>'mzp').
      and_return([foo, bar, baz])
    @statuses.should_receive(:add).with(any_args).at_least(3)
    @statuses.
      should_receive(:find_by_screen_name).
      with('mzp',:limit=>20).
      and_return([foo, bar, baz])
    @channel.should_receive(:message).with(anything, Net::IRC::Constants::NOTICE).at_least(3)
    call "#twitter","user",%w(mzp)
  end
end
