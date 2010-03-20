#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/command/favorite'
require 'atig/command/command_helper'

describe Atig::Command::Favorite do
  include CommandHelper
  before do
    @command = init Atig::Command::Favorite

    target = status 'blah blah', 'id'=>'1'
    entry  = entry user(1,'mzp'), target
    @res   = mock 'res'

    @statuses.stub!(:find_by_tid).with('a').and_return(entry)
  end

  it "should post fav" do
    @api.should_receive(:post).with("favorites/create/1")
    @channel.should_receive(:notify).with("FAV: mzp: blah blah")

    call "#twitter","fav",%w(a)
  end

  it "should post unfav" do
    @api.should_receive(:post).with("favorites/destroy/1")
    @channel.should_receive(:notify).with("UNFAV: mzp: blah blah")

    call "#twitter","unfav",%w(a)
  end
end
