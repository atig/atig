#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require File.expand_path( '../spec_helper', File.dirname(__FILE__) )
require 'atig/command/destroy'
require 'atig/command/command_helper'

describe Atig::Command::Destroy,"when status is not removed" do
  include CommandHelper

  before do
    @command = init Atig::Command::Destroy
  end

  it "should specified other's status" do
    entry  = entry user(2,'other'), status('blah blah', 'id'=>'1')
    @statuses.stub!(:find_by_tid).with('b').and_return(entry)

    @channel.should_receive(:notify).with("The status you specified by the ID tid is not yours.")
    call "#twitter","destory",%w(b)
  end
end

describe Atig::Command::Destroy,"when remove recently tweet" do
  include CommandHelper

  before do
    @command = init Atig::Command::Destroy

    target = status 'blah blah', 'id'=>'1'
    entry  = entry @me, target,'entry',1
    @res   = mock 'res'

    stub_status(:find_by_tid,'a' => entry)
    stub_status(:find_by_sid,'mzp:a' => entry)
    stub_status(:find_by_screen_name,'mzp' => [ entry ], :default=>[])

    # api
    @api.should_receive(:post).with("statuses/destroy/1")

    # notice
    @channel.should_receive(:notify).with("Destroyed: blah blah")

    # update topics
    new_entry  = entry @me, status('foo', 'id'=>'2')
    @gateway.should_receive(:topic).with(new_entry)

    @statuses.should_receive(:remove_by_id).with(1).and_return{
      @statuses.should_receive(:find_by_screen_name).with(@me.screen_name,:limit=>1).and_return{
        [ new_entry ]
      }
    }
  end

  it "should specified by tid" do
    call "#twitter","destory",%w(a)
  end

  it "should remove status by user" do
    call "#twitter","destory",%w(mzp)
  end

  it "should remove status by sid" do
    call "#twitter","destory",%w(mzp:a)
  end
end

describe Atig::Command::Destroy,"when remove old tweet" do
  include CommandHelper

  before do
    @command = init Atig::Command::Destroy

    target = status 'blah blah', 'id'=>'1'
    entry  = entry @me, target,'entry',1
    @res   = mock 'res'

    stub_status(:find_by_tid,'a' => entry)
    stub_status(:find_by_sid,'mzp:a' => entry)
    stub_status(:find_by_screen_name, @db.me.screen_name => [ entry ], :default=>[])

    # api
    @api.should_receive(:post).with("statuses/destroy/1")

    # notice
    @channel.should_receive(:notify).with("Destroyed: blah blah")

    # update topics
    @statuses.should_receive(:remove_by_id).with(1)
  end

  it "should specified by tid" do
    call "#twitter","destory",%w(a)
  end

  it "should remove status by sid" do
    call "#twitter","destory",%w(mzp:a)
  end
end
