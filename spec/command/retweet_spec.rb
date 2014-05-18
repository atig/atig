# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__ )
require 'atig/command/retweet'

describe Atig::Command::Retweet do
  include CommandHelper
  before do
    bitly =  double("Bitly")
    allow(bitly).to receive(:shorten){|s|
      "[#{s}]"
    }
    allow(Atig::Bitly).to receive(:no_login).and_return(bitly)

    @command = init Atig::Command::Retweet

    target = status 'blah blah blah blah blah blah blah blah', 'id'=>'1'
    entry  = entry user(1,'mzp'), target
    @res   = double 'res'

    stub_status(:find_by_tid,'a' => entry)
    stub_status(:find_by_sid,'mzp:a' => entry)
    stub_status(:find_by_screen_name,'mzp' => [ entry ], default:[])
  end

  it "should have command name" do
    expect(@gateway.names).to eq(%w(ort rt retweet qt))
  end

  it "should post official retweet without comment" do
    expect(@api).to receive(:post).with('statuses/retweet/1').and_return(@res)
    call "#twitter", 'rt', %w(a)
    expect(@gateway.updated).to  eq([ @res, '#twitter', 'RT to mzp: blah blah blah blah blah blah blah blah' ])
  end

  it "should post official retweet without comment by screen name" do
    expect(@api).to receive(:post).with('statuses/retweet/1').and_return(@res)
    call "#twitter", 'rt', %w(mzp)
    expect(@gateway.updated).to  eq([ @res, '#twitter', 'RT to mzp: blah blah blah blah blah blah blah blah' ])
  end

  it "should post official retweet without comment by sid" do
    expect(@api).to receive(:post).with('statuses/retweet/1').and_return(@res)
    call "#twitter", 'rt', %w(mzp:a)
    expect(@gateway.updated).to  eq([ @res, '#twitter', 'RT to mzp: blah blah blah blah blah blah blah blah' ])
  end

  it "should post un-official retweet with comment" do
    expect(@api).to receive(:post).with('statuses/update',:status=> "aaa RT @mzp: blah blah blah blah blah blah blah blah").and_return(@res)
    call "#twitter", 'rt', %w(a aaa)
    expect(@gateway.updated).to  eq([ @res, '#twitter', 'RT to mzp: blah blah blah blah blah blah blah blah' ])
  end

  it "should post un-official retweet with comment by screen name" do
    expect(@api).to receive(:post).with('statuses/update',:status=> "aaa RT @mzp: blah blah blah blah blah blah blah blah").and_return(@res)
    call "#twitter", 'rt', %w(mzp aaa)
    expect(@gateway.updated).to  eq([ @res, '#twitter', 'RT to mzp: blah blah blah blah blah blah blah blah' ])
  end

  it "should post un-official retweet with long comment" do
    expect(@api).to receive(:post).with('statuses/update',:status=> "#{'a' * 94} RT @mzp: b [https://twitter.com/mzp/status/1]").and_return(@res)
    call "#twitter", 'rt', ['a', 'a' * 94 ]
    expect(@gateway.updated).to  eq([ @res, '#twitter', 'RT to mzp: blah blah blah blah blah blah blah blah' ])
  end
end
