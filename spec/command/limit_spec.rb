# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__ )
require 'atig/command/limit'

describe Atig::Command::Limit do
  include CommandHelper

  before do
    @reset = ::Time.utc(2010,9,25,8,24,12)
    @command = init Atig::Command::Limit
    allow(@api).to receive(:limit).and_return(150)
    allow(@api).to receive(:remain).and_return(148)
    allow(@api).to receive(:reset).and_return(@reset)
  end

  it "should provide limit command" do
    expect(@gateway.names).to eq(['rls','limit','limits'])
  end

  it "should show limit" do
    expect(@channel).to receive(:notify).with("148 / 150 (reset at 2010-09-25 08:24:12)")
    call '#twitter', 'limit', []
    expect(@gateway.notified).to eq('#twitter')
  end
end
