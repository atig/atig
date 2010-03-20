#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/command/status'
require 'atig/command/command_helper'

describe Atig::Command::Status do
  before do
    @log    = mock 'log'
    @opts   = mock 'opts'
    context = OpenStruct.new :log=>@log, :opts=>@opts

    @channel    = mock 'channel'
    @gateway    = FakeGateway.new @channel
    @api        = mock 'api'
    @statuses   = mock 'status DB'
    @followings = mock 'following DB'
    @me         = user 1,'me'
    db = OpenStruct.new :statuses=>@statuses,:followings=>@followings,:me=>@me
    @command = Atig::Command::Status.new context, @gateway, FakeScheduler.new(@api), db
  end

  it "should have '/me status' name" do
    @gateway.names.should == ['status']
  end

  it "should post the status by API" do
    res = status('blah blah')
    @statuses.should_receive(:find_by_user).with(@me,:limit=>1).and_return(nil)
    @api.should_receive(:post).with('statuses/update', {:status=>'blah blah'}).and_return(res)

    @gateway.action.call '#twitter',"status blah blah","status",%w(blah blah)

    @gateway.updated.should  == [ res, '#twitter' ]
    @gateway.filtered.should == { :status => 'blah blah' }
  end

  it "should not post same post" do
    e = entry user(1,'mzp'), status('blah blah')
    @statuses.should_receive(:find_by_user).with(@me,:limit=>1).and_return(e)
    @channel.should_receive(:notify).with("You can't submit the same status twice in a row.")

    @gateway.action.call '#twitter',"status blah blah","status",%w(blah blah)
    @gateway.notified.should == '#twitter'
  end

  it "should not post over 140" do
    @statuses.should_receive(:find_by_user).with(@me,:limit=>1).and_return(nil)
    @channel.should_receive(:notify).with("You can't submit the status over 140 chars")

    @gateway.action.call '#twitter',"status #{'a'*141}","status",'a'*141
    @gateway.notified.should == '#twitter'
  end
end
