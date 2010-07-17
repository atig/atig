#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'fileutils'
require 'atig/db/statuses'

describe Atig::Db::Statuses do
  def status(id, text, time)
    OpenStruct.new(:id => id, :text => text, :created_at => time.strftime("%a %b %d %H:%M:%S +0000 %Y"))
  end

  def user(name)
    OpenStruct.new(:screen_name => name, :id => name)
  end

  before do
    @listened = []
    FileUtils.rm_f 'test.db'
    @db = Atig::Db::Statuses.new 'test.db'

    @a = status 10, 'a', Time.utc(2010,1,5)
    @b = status 20, 'b', Time.utc(2010,1,6)
    @c = status 30, 'c', Time.utc(2010,1,7)
    @d = status 40, 'd', Time.utc(2010,1,8)

    @alice = user 'alice'
    @bob = user 'bob'

    @db.add :status => @a , :user => @alice, :source => :srcA
    @db.add :status => @b , :user => @bob  , :source => :srcB
    @db.add :status => @c , :user => @alice, :source => :srcC
  end

  it "should be re-openable" do
    Atig::Db::Statuses.new 'test.db'
  end

  it "should call listeners" do
    entry = nil
    @db.listen{|x| entry = x }

    @db.add :status => @d, :user => @alice, :source => :timeline, :fuga => :hoge

    entry.source.should == :timeline
    entry.status.should == @d
    entry.tid.should match(/\w+/)
    entry.sid.should match(/\w+/)
    entry.user.should   == @alice
    entry.source.should == :timeline
    entry.fuga.should == :hoge
  end

  it "should not contain duplicate" do
    called = false
    @db.listen{|*_| called = true }

    @db.add :status => @c, :user => @bob, :source => :timeline
    called.should be_false
  end

  it "should be found by id" do
    entry = @db.find_by_id 1
    entry.id.should == 1
    entry.status.should == @a
    entry.user  .should == @alice
    entry.tid   .should match(/\w+/)
    entry.sid.should match(/\w+/)
  end

  it "should have unique tid" do
    db = Atig::Db::Statuses.new 'test.db'
    db.add :status => @d , :user => @alice, :source => :srcA

    a = @db.find_by_id(1)
    d = @db.find_by_id(4)
    a.tid.should_not == d.tid
    a.sid.should_not == d.cid
  end

  it "should be found all" do
    db = @db.find_all
    db.size.should == 3
    a,b,c = db

    a.status.should == @c
    a.user  .should == @alice
    a.tid   .should match(/\w+/)
    a.sid   .should match(/\w+/)

    b.status.should == @b
    b.user  .should == @bob
    b.tid   .should match(/\w+/)
    b.sid   .should match(/\w+/)

    c.status.should == @a
    c.user.should   == @alice
    c.tid.should    match(/\w+/)
    c.sid.should    match(/\w+/)
  end

  it "should be found by tid" do
    entry = @db.find_by_id(1)
    @db.find_by_tid(entry.tid).should == entry
  end

  it "should be found by sid" do
    entry = @db.find_by_id(1)
    @db.find_by_sid(entry.sid).should == entry
  end

  it "should be found by tid" do
    @db.find_by_tid('__').should be_nil
  end

  it "should be found by user" do
    a,b = *@db.find_by_user(@alice)

    a.status.should == @c
    a.user  .should == @alice
    a.tid   .should match(/\w+/)
    a.sid   .should match(/\w+/)

    b.status.should == @a
    b.user.should   == @alice
    b.tid.should    match(/\w+/)
    b.sid.should    match(/\w+/)
  end

  it "should be found by screen_name" do
    db = @db.find_by_screen_name('alice')
    db.size.should == 2
    a,b = db

    a.status.should == @c
    a.user  .should == @alice
    a.tid   .should match(/\w+/)
    a.sid   .should match(/\w+/)

    b.status.should == @a
    b.user.should   == @alice
    b.tid.should    match(/\w+/)
    b.sid.should    match(/\w+/)
  end

  it "should be found by screen_name with limit" do
    xs = @db.find_by_screen_name('alice', :limit => 1)
    xs.size.should == 1

    a,_ = xs
    a.status.should == @c
    a.user  .should == @alice
    a.tid   .should match(/\w+/)
    a.sid   .should match(/\w+/)
  end

  it "should remove by id" do
    @db.remove_by_id 1
    @db.find_by_id(1).should be_nil
  end

  it "should have uniq tid/sid when removed" do
    old = @db.find_by_id 3
    @db.remove_by_id 3
    @db.add :status => @c , :user => @alice, :source => :src
    new = @db.find_by_id 3

    old.tid.should_not == new.tid
    old.sid.should_not == new.sid
  end

  it "should cleanup" do
    Atig::Db::Statuses::Size = 10 # hack
    Atig::Db::Statuses::Size.times do|i|
      s = status i+100, 'a', Time.utc(2010,1,5)+i+1
      @db.add :status => s , :user => @alice  , :source => :srcB
    end
    @db.cleanup
    @db.find_by_status_id(@a.id).should == nil
  end
end
