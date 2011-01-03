#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require File.expand_path( '../spec_helper', File.dirname(__FILE__) )
require 'atig/command/dm'
require 'atig/command/command_helper'

describe Atig::Command::Dm do
  include CommandHelper
  before do
    @command = init Atig::Command::Dm
  end

  it "should have '/me dm' name" do
    @gateway.names.should == ['d', 'dm','dms']
  end

  it "should post the status by API" do
    @api.should_receive(:post).with('direct_messages/new',
                                    {:user=>'mzp', :text=> 'blah blah'})
    @channel.should_receive(:notify).with("Sent message to mzp: blah blah")
    call '#twitter', "dm", %w(mzp blah blah)
  end

  it "should post the status by API" do
    @channel.should_receive(:notify).with("/me dm <SCREEN_NAME> blah blah")
    call '#twitter', "dm", %w()
  end
end
