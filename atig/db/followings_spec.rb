#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'atig/db/followings'

describe Atig::Db::Followings,"when it is empty" do
  before do
    @db = Atig::Db::Followings.new
  end

  it "should be emtpy" do
    @db.empty?.should be_true
  end
end

describe Atig::Db::Followings,"when updated users" do
  def user(id, name, protect, only)
    user = stub("User-#{name}")
    user.stub!(:id).and_return(id)
    user.stub!(:screen_name).and_return(name)
    user.stub!(:protected).and_return(protect)
    user.stub!(:only).and_return(only)
    user
  end

  before do
    @alice    = user 1,'alice'   , false, false
    @bob      = user 2,'bob'     , true , false
    @charriey = user 3,'charriey', false, true

    @db = Atig::Db::Followings.new
    @db.update [ @alice, @bob ]

    @listen = {}
    @db.listen do|kind, users|
      @listen[kind] = users
    end
  end

  it "should return size" do
    @db.size.should == 2
  end

  it "should be invalidated" do
    called = false
    @db.on_invalidated do
      called = true
    end
    @db.invalidate

    called.should be_true
  end

  it "should not empty" do
    @db.empty?.should be_false
  end

  it "should call listener with :join" do
    @db.update [ @alice, @bob, @charriey ]
    @listen[:join].should == [ @charriey ]
    @listen[:part].should == nil
    @listen[:mode].should == nil
  end

  it "should call listener with :part" do
    @db.update [ @alice ]
    @listen[:join].should == nil
    @listen[:part].should == [ @bob ]
    @listen[:mode].should == nil
  end

  it "should call listener with :mode" do
    bob = user 5,'bob', false, false

    @db.update [ @alice, bob ]
    @listen[:join].should == nil
    @listen[:part].should == nil
    @listen[:mode].should == [ bob ]
  end

  it "should have users" do
    @db.users.should == [ @alice, @bob ]
  end

  it "should be found by screen_name" do
    @db.find_by_screen_name('alice').should == @alice
    @db.find_by_screen_name('???').should == nil
  end

  it "should check include" do
    alice = user @alice.id,'alice', true, true
    @db.include?(@charriey).should be_false
    @db.include?(@alice).should be_true
    @db.include?(alice).should be_true
  end
end
