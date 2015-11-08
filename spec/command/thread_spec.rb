# -*- mode:ruby; coding:utf-8 -*-

require 'atig/command/thread'

describe Atig::Command::Thread do
  include CommandHelper
  before do
    u = double 'user'
    @entries = [
                entry(u, status(''),'entry-0'),
                entry(u, status('','in_reply_to_status_id'=>2),'entry-1'),
                entry(u, status('','in_reply_to_status_id'=>3),'entry-2'),
                entry(u, status(''),'entry-3'),
                entry(u, status('','in_reply_to_status_id'=>5),'entry-4')
               ]
    @command = init Atig::Command::Thread
    @messages = []
    allow(@channel).to receive(:message){|entry,_|
      @messages.unshift entry
    }
    allow(@statuses).to receive(:find_by_status_id).with(anything){|id|
      @entries[id.to_i]
    }
  end

  it "should provide thread command" do
    expect(@gateway.names).to eq(%w( thread ))
  end

  it "should show the tweet" do
    expect(@statuses).to receive(:find_by_tid).with('a').and_return(@entries[0])

    call "#twitter","thread",%w(a)

    expect(@messages).to eq([ @entries[0] ])
  end

  it "should chain the tweets" do
    expect(@statuses).to receive(:find_by_tid).with('a').and_return(@entries[1])

    call "#twitter","thread",%w(a)

    expect(@messages).to eq(@entries[1..3])
  end

  it "should chain the tweets by screen name" do
    expect(@statuses).to receive(:find_by_tid).with('mzp').and_return(nil)
    expect(@statuses).to receive(:find_by_sid).with('mzp').and_return(nil)
    expect(@statuses).to receive(:find_by_screen_name).with('mzp',:limit=>1).and_return([ @entries[1] ])

    call "#twitter","thread",%w(mzp)

    expect(@messages).to eq(@entries[1..3])
  end

  it "should chain the tweets by sid" do
    expect(@statuses).to receive(:find_by_tid).with('mzp:a').and_return(nil)
    expect(@statuses).to receive(:find_by_sid).with('mzp:a').and_return(@entries[1])

    call "#twitter","thread",%w(mzp:a)

    expect(@messages).to eq(@entries[1..3])
  end



  it "should chain the tweets with limit" do
    expect(@statuses).to receive(:find_by_tid).with('a').and_return(@entries[1])

    call "#twitter","thread",%w(a 2)

    expect(@messages).to eq(@entries[1..2])
  end

  it "should get new tweets" do
    expect(@statuses).to receive(:find_by_tid).with('a').and_return(@entries[4])
    user   = user 1, 'mzp'
    status = status '','user'=>user
    entry  = entry user,status,'new-entry'
    expect(@statuses).to receive(:add).with(status: status, user: user, source: :thread){
      @entries << entry
    }
    expect(@api).to receive(:get).with('statuses/show/5').and_return(status)

    call "#twitter","thread",%w(a)

    expect(@messages).to eq([@entries[4], entry])
  end
end
