#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'fileutils'
require 'atig/db/statuses'

describe Atig::Db::Statuses do
  def status(id, text, time)
    OpenStruct.new(:id => id, :text => text, :created_at => time)
  end

  def user(name)
    OpenStruct.new(:screen_name => name, :id => name)
  end

  before do
    @listened = []
    FileUtils.rm_f 'test.db'
    @db = Atig::Db::Statuses.new 'test.db'

    @a = status 1, 'a',1
    @b = status 2, 'b',2
    @c = status 3, 'c',3
    @d = status 4, 'd',4

    @alice = user 'alice'
    @bob = user 'bob'

    @db.add :status => @a , :user => @alice, :source => :timeline
    @db.add :status => @b , :user => @bob  , :source => :timeline
    @db.add :status => @c , :user => @alice, :source => :timeline
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
    entry.status.should == @a
    entry.user  .should == @alice
    entry.tid   .should match(/\w+/)
  end

  it "should be found by tid" do
    entry = @db.find_by_id(1)
    @db.find_by_tid(entry.tid).should == entry
  end

  it "should be found by tid" do
    @db.find_by_tid('__').should be_nil
  end

  it "should be found by user" do
    a,b = *@db.find_by_user(@alice)

    a.status.should == @c
    a.user  .should == @alice
    a.tid   .should match(/\w+/)

    b.status.should == @a
    b.user.should   == @alice
    b.tid.should    match(/\w+/)
  end

  it "should be found by screen_name" do
    db = @db.find_by_screen_name('alice')
    db.size.should == 2
    a,b = db

    a.status.should == @c
    a.user  .should == @alice
    a.tid   .should match(/\w+/)

    b.status.should == @a
    b.user.should   == @alice
    b.tid.should    match(/\w+/)
  end

  it "should be found by screen_name with limit" do
    xs = @db.find_by_screen_name('alice', :limit => 1)
    xs.size.should == 1
  end
end
