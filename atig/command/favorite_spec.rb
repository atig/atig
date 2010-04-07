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

    @statuses.stub!(:find_by_tid).and_return{|tid|
      if tid == 'a' then
        entry
      else
        nil
      end
    }
    @statuses.stub!(:find_by_screen_name).with('mzp',:limit=>1).and_return([entry])
  end

  it "should post fav by tid" do
    @api.should_receive(:post).with("favorites/create/1")
    @channel.should_receive(:notify).with("FAV: mzp: blah blah")

    call "#twitter","fav",%w(a)
  end

  it "should post fav by screen name" do
    @api.should_receive(:post).with("favorites/create/1")
    @channel.should_receive(:notify).with("FAV: mzp: blah blah")

    call "#twitter","fav",%w(mzp)
  end

  it "should post unfav" do
    @api.should_receive(:post).with("favorites/destroy/1")
    @channel.should_receive(:notify).with("UNFAV: mzp: blah blah")

    call "#twitter","unfav",%w(a)
  end
end
