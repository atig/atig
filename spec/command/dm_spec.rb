# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__ )
require 'atig/command/dm'

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
                                    {:screen_name => 'mzp', :text => 'blah blah'})
    @channel.should_receive(:notify).with("Sent message to mzp: blah blah")
    call '#twitter', "dm", %w(mzp blah blah)
  end

  it "should post the status by API" do
    @channel.should_receive(:notify).with("/me dm <SCREEN_NAME> blah blah")
    call '#twitter', "dm", %w()
  end
end
