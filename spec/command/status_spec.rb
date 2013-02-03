# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__ )
require 'atig/command/status'

describe Atig::Command::Status do
  include CommandHelper
  before do
    @command = init Atig::Command::Status
  end

  it "should have '/me status' name" do
    @gateway.names.should == ['status']
  end

  it "should post the status by API" do
    res = status('blah blah')
    @statuses.should_receive(:find_by_user).with(@me,:limit=>1).and_return(nil)
    @api.should_receive(:post).with('statuses/update', {:status=>'blah blah'}).and_return(res)

    call '#twitter', "status", %w(blah blah)

    @gateway.updated.should  == [ res, '#twitter' ]
    @gateway.filtered.should == { :status => 'blah blah' }
  end

  if RUBY_VERSION >= '1.9'
    it "should post with japanese language" do
      res = status("あ"*140)
      @statuses.should_receive(:find_by_user).with(@me,:limit=>1).and_return(nil)
      @api.should_receive(:post).with('statuses/update', {:status=>"あ"*140}).and_return(res)

      call '#twitter', "status", ["あ" * 140]

      @gateway.updated.should  == [ res, '#twitter' ]
      @gateway.filtered.should == { :status => "あ" * 140 }
    end
  end

  it "should not post same post" do
    e = entry user(1,'mzp'), status('blah blah')
    @statuses.should_receive(:find_by_user).with(@me,:limit=>1).and_return([ e ] )
    @channel.should_receive(:notify).with("You can't submit the same status twice in a row.")

    call '#twitter', "status", %w(blah blah)
    @gateway.notified.should == '#twitter'
  end

  it "should not post over 140" do
    @statuses.should_receive(:find_by_user).with(@me,:limit=>1).and_return(nil)
    @channel.should_receive(:notify).with("You can't submit the status over 140 chars")

    call '#twitter', "status", [ 'a' * 141 ]
    @gateway.notified.should == '#twitter'
  end
end
