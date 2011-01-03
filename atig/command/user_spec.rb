#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require File.expand_path( '../spec_helper', File.dirname(__FILE__) )
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

  it "should get specified statuses" do
    foo = entry user(1,'mzp'),status('foo')
    bar = entry user(1,'mzp'),status('bar')
    baz = entry user(1,'mzp'),status('baz')
    @api.
      should_receive(:get).
      with('statuses/user_timeline',:count=>200,:screen_name=>'mzp').
      and_return([foo, bar, baz])
    @statuses.should_receive(:add).with(any_args).at_least(3)
    @statuses.
      should_receive(:find_by_screen_name).
      with('mzp',:limit=>200).
      and_return([foo, bar, baz])
    @channel.should_receive(:message).with(anything, Net::IRC::Constants::NOTICE).at_least(3)
    call "#twitter","user",%w(mzp 200)
  end
end
