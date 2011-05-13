# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__ )
require 'atig/command/autofix'
require 'atig/command/command_helper'

describe Atig::Command::Autofix do
  include CommandHelper
  before do
    @command = init Atig::Command::Autofix
    @opts.autofix = true
    target = status 'hello', 'id'=>'42'
    entry  = entry user(1,'mzp'), target, "entry", 1
    @statuses.should_receive(:find_by_user).with(@me,:limit=>1).and_return([ entry ])
  end

  it "should post normal tweet" do
    res = status('blah blah')
    @api.should_receive(:post).with('statuses/update', {:status=>'blah blah'}).and_return(res)

    call '#twitter', "autofix", %w(blah blah)
  end

  it "should delete old similar tweet" do
    res = status('hillo')
    @api.should_receive(:post).with('statuses/update', {:status=>'hillo'}).and_return(res)
    @api.should_receive(:post).with("statuses/destroy/42")
    @statuses.should_receive(:remove_by_id).with(1)

    @channel.should_receive(:notify).with("Similar update in previous. Conclude that it has error.")
    @channel.should_receive(:notify).with("And overwrite previous as new status: hillo")

    call '#twitter', "autofix", %w(hillo)
  end
end
