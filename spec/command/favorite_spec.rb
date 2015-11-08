# -*- mode:ruby; coding:utf-8 -*-

require 'atig/command/favorite'

describe Atig::Command::Favorite do
  include CommandHelper
  before do
    @command = init Atig::Command::Favorite

    target = status 'blah blah', 'id'=>'1'
    entry  = entry user(1,'mzp'), target
    @res   = double 'res'

    stub_status(:find_by_tid,'a' => entry)
    stub_status(:find_by_sid,'mzp:a' => entry)
    stub_status(:find_by_screen_name,'mzp' => [ entry ], default:[])
  end

  it "should post fav by tid" do
    expect(@api).to receive(:post).with("favorites/create", {id: "1"})
    expect(@channel).to receive(:notify).with("FAV: mzp: blah blah")

    call "#twitter","fav",%w(a)
  end

  it "should post fav by sid" do
    expect(@api).to receive(:post).with("favorites/create", {id: "1"})
    expect(@channel).to receive(:notify).with("FAV: mzp: blah blah")

    call "#twitter","fav",%w(mzp:a)
  end

  it "should post fav by screen name" do
    expect(@api).to receive(:post).with("favorites/create", {id: "1"})
    expect(@channel).to receive(:notify).with("FAV: mzp: blah blah")

    call "#twitter","fav",%w(mzp)
  end

  it "should post fav by screen name with at" do
    expect(@api).to receive(:post).with("favorites/create", {id: "1"})
    expect(@channel).to receive(:notify).with("FAV: mzp: blah blah")

    call "#twitter","fav",%w(@mzp)
  end

  it "should post unfav" do
    expect(@api).to receive(:post).with("favorites/destroy", {id: "1"})
    expect(@channel).to receive(:notify).with("UNFAV: mzp: blah blah")

    call "#twitter","unfav",%w(a)
  end
end
