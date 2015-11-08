# -*- mode:ruby; coding:utf-8 -*-

require 'atig/db/followings'

describe Atig::Db::Followings,"when it is empty" do
  before do
    FileUtils.rm_f 'following.test.db'
    @db = Atig::Db::Followings.new('following.test.db')
  end

  after(:all) do
    FileUtils.rm_f 'following.test.db'
  end

  it "should be emtpy" do
    expect(@db.empty?).to be_truthy
  end
end

describe Atig::Db::Followings,"when updated users" do
  def user(id, name, protect, only)
    OpenStruct.new(id: id, screen_name:name, protected:protect, only:only)
  end

  before do
    @alice    = user 1,'alice'   , false, false
    @bob      = user 2,'bob'     , true , false
    @charriey = user 3,'charriey', false, true

    FileUtils.rm_f 'following.test.db'
    @db = Atig::Db::Followings.new('following.test.db')
    @db.update [ @alice, @bob ]

    @listen = {}
    @db.listen do|kind, users|
      @listen[kind] = users
    end
  end

  after(:all) do
    FileUtils.rm_f 'following.test.db'
  end

  it "should return size" do
    expect(@db.size).to eq(2)
  end

  it "should be invalidated" do
    called = false
    @db.on_invalidated do
      called = true
    end
    @db.invalidate

    expect(called).to be_truthy
  end

  it "should not empty" do
    expect(@db.empty?).to be_falsey
  end

  it "should call listener with :join" do
    @db.update [ @alice, @bob, @charriey ]
    expect(@listen[:join]).to eq([ @charriey ])
    expect(@listen[:part]).to eq(nil)
    expect(@listen[:mode]).to eq(nil)
  end

  it "should call listener with :part" do
    @db.update [ @alice ]
    expect(@listen[:join]).to eq(nil)
    expect(@listen[:part]).to eq([ @bob ])
    expect(@listen[:mode]).to eq(nil)
  end

  it "should not found removed user[BUG]" do
    expect(@db.include?(@bob)).to eq(true)
    @db.update [ @alice ]
    # now, @bob is not member
    expect(@db.include?(@bob)).to eq(false)
  end

  it "should call listener with :mode" do
    bob = user 5,'bob', false, false

    @db.update [ @alice, bob ]
    expect(@listen[:join]).to eq(nil)
    expect(@listen[:part]).to eq(nil)
    expect(@listen[:mode]).to eq([ bob ])
  end

  it "should have users" do
    expect(@db.users).to eq([ @alice, @bob ])
  end

  it "should be found by screen_name" do
    expect(@db.find_by_screen_name('alice')).to eq(@alice)
    expect(@db.find_by_screen_name('???')).to eq(nil)
  end

  it "should check include" do
    alice = user @alice.id,'alice', true, true
    expect(@db.include?(@charriey)).to be_falsey
    expect(@db.include?(@alice)).to be_truthy
    expect(@db.include?(alice)).to be_truthy
  end
end
