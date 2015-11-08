# -*- mode:ruby; coding:utf-8 -*-

require 'atig/db/lists'

describe Atig::Db::Lists do
  def user(id, name, protect, only)
    OpenStruct.new(id: id, screen_name:name, protected:protect, only:only)
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

  after(:all) do
    %w(test-a.db test-b.db).each do |file|
      FileUtils.rm_f file
    end
  end

  it "should have list" do
    @lists.update("a" => [ @alice, @bob ],
                  "b" => [ @alice, @bob , @charriey ])

    expect(@lists.find_by_screen_name('alice').sort).to eq(["a", "b"])
    expect(@lists.find_by_screen_name('charriey')).to eq(["b"])
  end

  it "should have lists" do
    @lists.update("a" => [ @alice, @bob ],
                  "b" => [ @alice, @bob , @charriey ])

    expect(@lists.find_by_list_name('a')).to eq([ @alice, @bob ])
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
    expect(hash).to eq(data)
  end

  it "should call listener when new list" do
    @lists.update("a" => [ @alice, @bob ])

    expect(@args.keys).to include(:new, :join)
    expect(@args[:new]).to eq([ "a" ])
    expect(@args[:join]).to eq([ "a", [ @alice, @bob ] ])
  end

  it "should call listener when partcial update" do
    @lists.update("a" => [ @alice ])
    @lists["a"].update([ @alice, @bob, @charriey ])
    expect(@args[:join]).to eq(["a", [ @bob, @charriey ]])
  end

  it "should call on_invalidated" do
    called = false
    @lists.on_invalidated do|name|
      expect(name).to eq("a")
      called = true
    end
    @lists.invalidate("a")

    expect(called).to be_truthy
  end

  it "should call listener when delete list" do
    @lists.update("a" => [ @alice, @bob ])
    @lists.update({})
    expect(@args.keys).to include(:new, :join, :del)
    expect(@args[:del]).to eq(["a"])
  end

  it "should call listener when join user" do
    @lists.update("a" => [ @alice ])
    @lists.update("a" => [ @alice, @bob, @charriey ])

    expect(@args[:join]).to eq(["a", [ @bob, @charriey ]])
  end

  it "should call listener when exit user" do
    @lists.update("a" => [ @alice, @bob, @charriey ])
    @lists.update("a" => [ @alice ])
    expect(@args[:part]).to eq(["a", [ @bob, @charriey ]])
  end

  it "should call listener when change user mode" do
    @lists.update("a" => [ @alice, @bob ])
    bob = user @bob.id, 'bob', false, false
    @lists.update("a" => [ @alice, bob ])

    expect(@args[:mode]).to eq([ "a", [ bob ]])
  end
end
