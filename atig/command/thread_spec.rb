#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/command/thread'
require 'atig/command/command_helper'

describe Atig::Command::Thread do
  include CommandHelper
  before do
    u = mock 'user'
    @entries = [
                entry(u, status(''),'entry-0'),
                entry(u, status('','in_reply_to_status_id'=>2),'entry-1'),
                entry(u, status('','in_reply_to_status_id'=>3),'entry-2'),
                entry(u, status(''),'entry-3'),
                entry(u, status('','in_reply_to_status_id'=>5),'entry-4')
               ]
    @command = init Atig::Command::Thread
    @messages = []
    @channel.stub!(:message).and_return{|entry,_|
      @messages << entry
    }
    @statuses.stub!(:find_by_id).with(anything).and_return{|id|
      @entries[id.to_i]
    }
  end

  it "should provide thread command" do
    @gateway.names.should == %w( thread )
  end

  it "should show the tweet" do
    @statuses.should_receive(:find_by_tid).with('a').and_return(@entries[0])

    call "#twitter","thread",%w(a)

    @messages.should == [ @entries[0] ]
  end

  it "should chain the tweets" do
    @statuses.should_receive(:find_by_tid).with('a').and_return(@entries[1])

    call "#twitter","thread",%w(a)

    @messages.should == @entries[1..3]
  end

  it "should chain the tweets with limit" do
    @statuses.should_receive(:find_by_tid).with('a').and_return(@entries[1])

    call "#twitter","thread",%w(a 2)

    @messages.should == @entries[1..2]
  end

  it "should get new tweets" do
    @statuses.should_receive(:find_by_tid).with('a').and_return(@entries[4])
    user   = user 1, 'mzp'
    status = status '','user'=>user
    entry  = entry user,status,'new-entry'
    @statuses.should_receive(:add).with(:status => status, :user => user, :source=>:thread).and_return{
      @entries << entry
    }
    @api.should_receive(:get).with('statuses/show/5').and_return(status)

    call "#twitter","thread",%w(a)

    @messages.should == [@entries[4], entry]
  end
end
