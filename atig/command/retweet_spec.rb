#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require File.expand_path( '../spec_helper', File.dirname(__FILE__) )
require 'atig/command/retweet'
require 'atig/command/command_helper'

describe Atig::Command::Retweet do
  include CommandHelper
  before do
    bitly =  mock("Bitly")
    bitly.stub!(:shorten).and_return{|s|
      "[#{s}]"
    }
    Atig::Bitly.stub!(:no_login).and_return(bitly)

    @command = init Atig::Command::Retweet

    target = status 'blah blah blah blah blah blah blah blah', 'id'=>'1'
    entry  = entry user(1,'mzp'), target
    @res   = mock 'res'

    stub_status(:find_by_tid,'a' => entry)
    stub_status(:find_by_sid,'mzp:a' => entry)
    stub_status(:find_by_screen_name,'mzp' => [ entry ], :default=>[])
  end

  it "should have command name" do
    @gateway.names.should == %w(ort rt retweet qt)
  end

  it "should post official retweet without comment" do
    @api.should_receive(:post).with('statuses/retweet/1').and_return(@res)
    call "#twitter", 'rt', %w(a)
    @gateway.updated.should  == [ @res, '#twitter', 'RT to mzp: blah blah blah blah blah blah blah blah' ]
  end

  it "should post official retweet without comment by screen name" do
    @api.should_receive(:post).with('statuses/retweet/1').and_return(@res)
    call "#twitter", 'rt', %w(mzp)
    @gateway.updated.should  == [ @res, '#twitter', 'RT to mzp: blah blah blah blah blah blah blah blah' ]
  end

  it "should post official retweet without comment by sid" do
    @api.should_receive(:post).with('statuses/retweet/1').and_return(@res)
    call "#twitter", 'rt', %w(mzp:a)
    @gateway.updated.should  == [ @res, '#twitter', 'RT to mzp: blah blah blah blah blah blah blah blah' ]
  end

  it "should post un-official retweet with comment" do
    @api.should_receive(:post).with('statuses/update',:status=> "aaa RT @mzp: blah blah blah blah blah blah blah blah").and_return(@res)
    call "#twitter", 'rt', %w(a aaa)
    @gateway.updated.should  == [ @res, '#twitter', 'RT to mzp: blah blah blah blah blah blah blah blah' ]
  end

  it "should post un-official retweet with comment by screen name" do
    @api.should_receive(:post).with('statuses/update',:status=> "aaa RT @mzp: blah blah blah blah blah blah blah blah").and_return(@res)
    call "#twitter", 'rt', %w(mzp aaa)
    @gateway.updated.should  == [ @res, '#twitter', 'RT to mzp: blah blah blah blah blah blah blah blah' ]
  end

  it "should post un-official retweet with long comment" do
    @api.should_receive(:post).with('statuses/update',:status=> "#{'a' * 95} RT @mzp: b [http://twitter.com/mzp/status/1]").and_return(@res)
    call "#twitter", 'rt', ['a', 'a' * 95 ]
    @gateway.updated.should  == [ @res, '#twitter', 'RT to mzp: blah blah blah blah blah blah blah blah' ]
  end
end
