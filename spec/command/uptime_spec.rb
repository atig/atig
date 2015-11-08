# -*- mode:ruby; coding:utf-8 -*-

require 'atig/command/uptime'

describe Atig::Command::Uptime do
  include CommandHelper

  before do
    expect(::Time).to receive(:now).and_return(::Time.at(0))
    @command = init Atig::Command::Uptime
  end

  it "should register uptime command" do
    expect(@gateway.names).to eq(['uptime'])
  end

  it "should return mm:ss(min)" do
    expect(::Time).to receive(:now).and_return(::Time.at(0))
    expect(@channel).to receive(:notify).with("00:00")
    call '#twitter', 'uptime', []

    expect(@gateway.notified).to eq('#twitter')
  end

  it "should return mm:ss(max)" do
    expect(::Time).to receive(:now).and_return(::Time.at(60*60-1))
    expect(@channel).to receive(:notify).with("59:59")
    call '#twitter', 'uptime', []

    expect(@gateway.notified).to eq('#twitter')
  end

  it "should return hh:mm:ss(min)" do
    expect(::Time).to receive(:now).and_return(::Time.at(60*60))
    expect(@channel).to receive(:notify).with("01:00:00")
    call '#twitter', 'uptime', []
    expect(@gateway.notified).to eq('#twitter')
  end

  it "should return hh:mm:ss(max)" do
    expect(::Time).to receive(:now).and_return(::Time.at(24*60*60-1))
    expect(@channel).to receive(:notify).with("23:59:59")
    call '#twitter', 'uptime', []
    expect(@gateway.notified).to eq('#twitter')
  end

  it "should return dd days hh:mm:ss" do
    expect(::Time).to receive(:now).and_return(::Time.at(24*60*60))
    expect(@channel).to receive(:notify).with("1 days 00:00")
    call '#twitter', 'uptime', []
    expect(@gateway.notified).to eq('#twitter')
  end
end
