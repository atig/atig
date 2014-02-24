# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__ )
require 'atig/command/dm'

describe Atig::Command::Dm do
  include CommandHelper
  before do
    @command = init Atig::Command::Dm
  end

  it "should have '/me dm' name" do
    expect(@gateway.names).to eq(['d', 'dm','dms'])
  end

  it "should post the status by API" do
    expect(@api).to receive(:post).with('direct_messages/new',
                                    {:screen_name => 'mzp', :text => 'blah blah'})
    expect(@channel).to receive(:notify).with("Sent message to mzp: blah blah")
    call '#twitter', "dm", %w(mzp blah blah)
  end

  it "should post the status by API" do
    expect(@channel).to receive(:notify).with("/me dm <SCREEN_NAME> blah blah")
    call '#twitter', "dm", %w()
  end
end
