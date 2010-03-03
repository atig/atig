#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

describe Atig::Db::Lists do
  def user(name, protect, only)
    user = stub("user-#{name}")
    user.stub!(:screen_name).and_return(name)
    user.stub!(:protected).and_return(protect)
    user.stub!(:only).and_return(only)
    user
  end

  before do
    @lists = Atig::Db::Lists.new
    @alice    = user 'alice'   , false, false
    @bob      = user 'bob'     , true , false
    @charriey = user 'charriey', false, true

    @args = []
    @lists.listen{|*args| @args << args }
  end

  it "should have list" do
    @lists.update("a", [ @alice, @bob ])
    @lists.update("b", [ @alice, @bob , @charriey ])

    @lists.find_by_screen_name('alice').should == ["a", "b"]
    @lists.find_by_screen_name('charriey').should == ["b"]
  end

  it "should call listener when new list" do

  end

  it "should call listener when delete list" do

  end

  it "should call listener when join user" do

  end

  it "should call listener when exit user" do

  end

  it "should call listener when change user mode" do

  end
end

