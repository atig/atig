# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__ )
require 'atig/command/favorite'
require 'atig/command/command_helper'

describe Atig::Command::Favorite do
  include CommandHelper
  before do
    @command = init Atig::Command::Favorite

    target = status 'blah blah', 'id'=>'1'
    entry  = entry user(1,'mzp'), target
    @res   = mock 'res'

    stub_status(:find_by_tid,'a' => entry)
    stub_status(:find_by_sid,'mzp:a' => entry)
    stub_status(:find_by_screen_name,'mzp' => [ entry ], :default=>[])
  end

  it "should post fav by tid" do
    @api.should_receive(:post).with("favorites/create/1")
    @channel.should_receive(:notify).with("FAV: mzp: blah blah")

    call "#twitter","fav",%w(a)
  end

  it "should post fav by sid" do
    @api.should_receive(:post).with("favorites/create/1")
    @channel.should_receive(:notify).with("FAV: mzp: blah blah")

    call "#twitter","fav",%w(mzp:a)
  end

  it "should post fav by screen name" do
    @api.should_receive(:post).with("favorites/create/1")
    @channel.should_receive(:notify).with("FAV: mzp: blah blah")

    call "#twitter","fav",%w(mzp)
  end

  it "should post fav by screen name with at" do
    @api.should_receive(:post).with("favorites/create/1")
    @channel.should_receive(:notify).with("FAV: mzp: blah blah")

    call "#twitter","fav",%w(@mzp)
  end

  it "should post unfav" do
    @api.should_receive(:post).with("favorites/destroy/1")
    @channel.should_receive(:notify).with("UNFAV: mzp: blah blah")

    call "#twitter","unfav",%w(a)
  end
end
