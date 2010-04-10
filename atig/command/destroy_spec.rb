#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/command/destroy'
require 'atig/command/command_helper'

describe Atig::Command::Destroy do
  include CommandHelper
  before do
    @command = init Atig::Command::Destroy

    target = status 'blah blah', 'id'=>'1'
    entry  = entry @me, target
    @res   = mock 'res'

    stub_status(:find_by_tid,'a' => entry)
    stub_status(:find_by_screen_name,'mzp' => [ entry ], :default=>[])
  end

  it "should have name" do
    @gateway.names.should == %w(destroy remove rm)
  end

  it "should remove status" do
    @api.should_receive(:post).with("statuses/destroy/1")
    @channel.should_receive(:notify).with("Destroyed: blah blah")

    call "#twitter","destory",%w(a)
  end

  it "should remove status by user" do
    @api.should_receive(:post).with("statuses/destroy/1")
    @channel.should_receive(:notify).with("Destroyed: blah blah")

    call "#twitter","destory",%w(mzp)
  end

  it "should not remove other's status" do
    entry  = entry user(2,'other'), status('blah blah', 'id'=>'1')
    @statuses.stub!(:find_by_tid).with('b').and_return(entry)

    @channel.should_receive(:notify).with("The status you specified by the ID tid is not yours.")
    call "#twitter","destory",%w(b)
  end
end
