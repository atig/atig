# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__ )
require 'atig/command/status'

describe Atig::Command::Status do
  include CommandHelper
  before do
    @command = init Atig::Command::Status
  end

  it "should have '/me status' name" do
    expect(@gateway.names).to eq(['status'])
  end

  it "should post the status by API" do
    res = status('blah blah')
    expect(@statuses).to receive(:find_by_user).with(@me,:limit=>1).and_return(nil)
    expect(@api).to receive(:post).with('statuses/update', {status:'blah blah'}).and_return(res)

    call '#twitter', "status", %w(blah blah)

    expect(@gateway.updated).to  eq([ res, '#twitter' ])
    expect(@gateway.filtered).to eq({ status: 'blah blah' })
  end

  it "should post with japanese language" do
    res = status("あ"*140)
    expect(@statuses).to receive(:find_by_user).with(@me,:limit=>1).and_return(nil)
    expect(@api).to receive(:post).with('statuses/update', {status:"あ"*140}).and_return(res)

    call '#twitter', "status", ["あ" * 140]

    expect(@gateway.updated).to  eq([ res, '#twitter' ])
    expect(@gateway.filtered).to eq({ status: "あ" * 140 })
  end

  it "should post the status even if has long URL" do
    res = status("https://www.google.co.jp/search?q=%E3%83%AB%E3%83%93%E3%83%BC%E3%82%92%E7%94%A8%E3%81%84%E3%81%9F%E3%82%A2%E3%83%97%E3%83%AA%E3%82%B1%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3%E3%81%AE%E9%96%8B%E7%99%BA&safe=off")
    expect(@statuses).to receive(:find_by_user).with(@me,:limit=>1).and_return(nil)
    expect(@api).to receive(:post).with('statuses/update', {status:'https://www.google.co.jp/search?q=%E3%83%AB%E3%83%93%E3%83%BC%E3%82%92%E7%94%A8%E3%81%84%E3%81%9F%E3%82%A2%E3%83%97%E3%83%AA%E3%82%B1%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3%E3%81%AE%E9%96%8B%E7%99%BA&safe=off'}).and_return(res)

    call '#twitter', "status", ['https://www.google.co.jp/search?q=%E3%83%AB%E3%83%93%E3%83%BC%E3%82%92%E7%94%A8%E3%81%84%E3%81%9F%E3%82%A2%E3%83%97%E3%83%AA%E3%82%B1%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3%E3%81%AE%E9%96%8B%E7%99%BA&safe=off']

    expect(@gateway.updated).to  eq([ res, '#twitter' ])
    expect(@gateway.filtered).to eq({ status: 'https://www.google.co.jp/search?q=%E3%83%AB%E3%83%93%E3%83%BC%E3%82%92%E7%94%A8%E3%81%84%E3%81%9F%E3%82%A2%E3%83%97%E3%83%AA%E3%82%B1%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3%E3%81%AE%E9%96%8B%E7%99%BA&safe=off'})
  end

  it "should not post same post" do
    e = entry user(1,'mzp'), status('blah blah')
    expect(@statuses).to receive(:find_by_user).with(@me,:limit=>1).and_return([ e ] )
    expect(@channel).to receive(:notify).with("You can't submit the same status twice in a row.")

    call '#twitter', "status", %w(blah blah)
    expect(@gateway.notified).to eq('#twitter')
  end

  it "should not post over 140" do
    expect(@statuses).to receive(:find_by_user).with(@me,:limit=>1).and_return(nil)
    expect(@channel).to receive(:notify).with("You can't submit the status over 140 chars")

    call '#twitter', "status", [ 'a' * 141 ]
    expect(@gateway.notified).to eq('#twitter')
  end
end
