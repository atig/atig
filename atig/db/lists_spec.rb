#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/db/lists'

describe Atig::Db::Lists do
  def user(id, name, protect, only)
    OpenStruct.new(:id => id, :screen_name=>name, :protected=>protect, :only=>only)
  end

  before do
    FileUtils.rm_rf "test-a.db"
    @lists = Atig::Db::Lists.new "test-%s.db"
    @alice    = user 1,'alice'   , false, false
    @bob      = user 2,'bob'     , true , false
    @charriey = user 3,'charriey', false, true

    @args = {}
    @lists.listen{|kind,*args| @args[kind] = args }
  end

  it "should have list" do
    @lists.update("a" => [ @alice, @bob ],
                  "b" => [ @alice, @bob , @charriey ])

    @lists.find_by_screen_name('alice').sort.should == ["a", "b"]
    @lists.find_by_screen_name('charriey').should == ["b"]
  end

  it "should have lists" do
    @lists.update("a" => [ @alice, @bob ],
                  "b" => [ @alice, @bob , @charriey ])

    @lists.find_by_list_name('a').should == [ @alice, @bob ]
  end

  it "should have each" do
    data = {
      "a" => [ @alice, @bob ],
      "b" => [ @alice, @bob , @charriey ]
    }
    @lists.update(data)

    hash = {}
    @lists.each do|name,users|
      hash[name] = users
    end
    hash.should == data
  end

  it "should call listener when new list" do
    @lists.update("a" => [ @alice, @bob ])

    @args.keys.should include(:new, :join)
    @args[:new].should == [ "a" ]
    @args[:join].should == [ "a", [ @alice, @bob ] ]
  end

  it "should call listener when partcial update" do
    @lists.update("a" => [ @alice ])
    @lists["a"].update([ @alice, @bob, @charriey ])
    @args[:join].should == ["a", [ @bob, @charriey ]]
  end

  it "should call on_invalidated" do
    called = false
    @lists.on_invalidated do|name|
      name.should == "a"
      called = true
    end
    @lists.invalidate("a")

    called.should be_true
  end

  it "should call listener when delete list" do
    @lists.update("a" => [ @alice, @bob ])
    @lists.update({})
    @args.keys.should include(:new, :join, :del)
    @args[:del].should == ["a"]
  end

  it "should call listener when join user" do
    @lists.update("a" => [ @alice ])
    @lists.update("a" => [ @alice, @bob, @charriey ])

    @args[:join].should == ["a", [ @bob, @charriey ]]
  end

  it "should call listener when exit user" do
    @lists.update("a" => [ @alice, @bob, @charriey ])
    @lists.update("a" => [ @alice ])
    @args[:part].should == ["a", [ @bob, @charriey ]]
  end

  it "should call listener when change user mode" do
    @lists.update("a" => [ @alice, @bob ])
    bob = user @bob.id, 'bob', false, false
    @lists.update("a" => [ @alice, bob ])

    @args[:mode].should == [ "a", [ bob ]]
  end
end

