# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__ )
require 'atig/command/location'

describe Atig::Command::Location do
  include CommandHelper

  before do
    @command = init Atig::Command::Location
  end

  it "should update location" do
    expect(@api).to receive(:post).with('account/update_profile',:location=>'some place')
    expect(@channel).to receive(:notify).with("You are in some place now.")
    call '#twitter','location',%w(some place)
  end

  it "should reset location" do
    expect(@api).to receive(:post).with('account/update_profile',:location=>'')
    expect(@channel).to receive(:notify).with("You are nowhere now.")
    call '#twitter','location',%w()
  end
end
