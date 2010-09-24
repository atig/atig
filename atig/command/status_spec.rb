#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/spec_helper'
require 'atig/command/status'
require 'atig/command/command_helper'

describe Atig::Command::Status do
  include CommandHelper
  before do
    @command = init Atig::Command::Status
  end

  it "should have '/me status' name" do
    @gateway.names.should == ['status']
  end

  it "should post the status by API" do
    res = status('blah blah')
    @statuses.should_receive(:find_by_user).with(@me,:limit=>1).and_return(nil)
    @api.should_receive(:post).with('statuses/update', {:status=>'blah blah'}).and_return(res)

    call '#twitter', "status", %w(blah blah)

    @gateway.updated.should  == [ res, '#twitter' ]
    @gateway.filtered.should == { :status => 'blah blah' }
  end

  it "should not post same post" do
    e = entry user(1,'mzp'), status('blah blah')
    @statuses.should_receive(:find_by_user).with(@me,:limit=>1).and_return([ e ] )
    @channel.should_receive(:notify).with("You can't submit the same status twice in a row.")

    call '#twitter', "status", %w(blah blah)
    @gateway.notified.should == '#twitter'
  end

  it "should not post over 140" do
    @statuses.should_receive(:find_by_user).with(@me,:limit=>1).and_return(nil)
    @channel.should_receive(:notify).with("You can't submit the status over 140 chars")

    call '#twitter', "status", [ 'a' * 141 ]
    @gateway.notified.should == '#twitter'
  end
end
