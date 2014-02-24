# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__ )
require 'atig/command/refresh'
require 'atig/command/info'

describe Atig::Command::Refresh do
  include CommandHelper

  before do
    @command = init Atig::Command::Refresh
  end

  it "should refresh all" do
    expect(@followings).to receive(:invalidate)
    expect(@lists).to receive(:invalidate).with(:all)
    expect(@channel).to receive(:notify).with("refresh followings/lists...")

    call '#twitter','refresh', []
  end
end
