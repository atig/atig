# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__ )
require 'atig/command/autofix'

describe Atig::Command::Autofix do
  include CommandHelper
  before do
    @command = init Atig::Command::Autofix
    @opts.autofix = true
    target = status 'hello', 'id'=>'42'
    entry  = entry user(1,'mzp'), target, "entry", 1
    expect(@statuses).to receive(:find_by_user).with(@me,:limit=>1).and_return([ entry ])
  end

  it "should post normal tweet" do
    res = status('blah blah')
    expect(@api).to receive(:post).with('statuses/update', {status:'blah blah'}).and_return(res)

    call '#twitter', "autofix", %w(blah blah)
  end

  it "should delete old similar tweet" do
    res = status('hillo')
    expect(@api).to receive(:post).with('statuses/update', {status:'hillo'}).and_return(res)
    expect(@api).to receive(:post).with("statuses/destroy/42")
    expect(@statuses).to receive(:remove_by_id).with(1)

    expect(@channel).to receive(:notify).with("Similar update in previous. Conclude that it has error.")
    expect(@channel).to receive(:notify).with("And overwrite previous as new status: hillo")

    call '#twitter', "autofix", %w(hillo)
  end
end
