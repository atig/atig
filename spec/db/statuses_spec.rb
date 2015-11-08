# -*- mode:ruby; coding:utf-8 -*-

require 'fileutils'
require 'atig/db/statuses'

describe Atig::Db::Statuses do
  def status(id, text, time)
    OpenStruct.new(id: id, text: text, created_at: time.strftime("%a %b %d %H:%M:%S +0000 %Y"))
  end

  def user(name)
    OpenStruct.new(screen_name: name, id: name)
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

    @db.add status: @a , user: @alice, source: :srcA
    @db.add status: @b , user: @bob  , source: :srcB
    @db.add status: @c , user: @alice, source: :srcC
  end

  after(:all) do
    FileUtils.rm_f 'test.db'
  end

  it "should be re-openable" do
    Atig::Db::Statuses.new 'test.db'
  end

  it "should call listeners" do
    entry = nil
    @db.listen{|x| entry = x }

    @db.add status: @d, user: @alice, source: :timeline, fuga: :hoge

    expect(entry.source).to eq(:timeline)
    expect(entry.status).to eq(@d)
    expect(entry.tid).to match(/\w+/)
    expect(entry.sid).to match(/\w+/)
    expect(entry.user).to   eq(@alice)
    expect(entry.source).to eq(:timeline)
    expect(entry.fuga).to eq(:hoge)
  end

  it "should not contain duplicate" do
    called = false
    @db.listen{|*_| called = true }

    @db.add status: @c, user: @bob, source: :timeline
    expect(called).to be_falsey
  end

  it "should be found by id" do
    entry = @db.find_by_id 1
    expect(entry.id).to eq(1)
    expect(entry.status).to eq(@a)
    expect(entry.user)  .to eq(@alice)
    expect(entry.tid)   .to match(/\w+/)
    expect(entry.sid).to match(/\w+/)
  end

  it "should have unique tid" do
    db = Atig::Db::Statuses.new 'test.db'
    db.add status: @d , user: @alice, source: :srcA

    a = @db.find_by_id(1)
    d = @db.find_by_id(4)
    expect(a.tid).not_to eq(d.tid)
    expect(a.sid).not_to eq(d.cid)
  end

  it "should be found all" do
    db = @db.find_all
    expect(db.size).to eq(3)
    a,b,c = db

    expect(a.status).to eq(@c)
    expect(a.user)  .to eq(@alice)
    expect(a.tid)   .to match(/\w+/)
    expect(a.sid)   .to match(/\w+/)

    expect(b.status).to eq(@b)
    expect(b.user)  .to eq(@bob)
    expect(b.tid)   .to match(/\w+/)
    expect(b.sid)   .to match(/\w+/)

    expect(c.status).to eq(@a)
    expect(c.user).to   eq(@alice)
    expect(c.tid).to    match(/\w+/)
    expect(c.sid).to    match(/\w+/)
  end

  it "should be found by tid" do
    entry = @db.find_by_id(1)
    expect(@db.find_by_tid(entry.tid)).to eq(entry)
  end

  it "should be found by sid" do
    entry = @db.find_by_id(1)
    expect(@db.find_by_sid(entry.sid)).to eq(entry)
  end

  it "should be found by tid" do
    expect(@db.find_by_tid('__')).to be_nil
  end

  it "should be found by user" do
    a,b = *@db.find_by_user(@alice)

    expect(a.status).to eq(@c)
    expect(a.user)  .to eq(@alice)
    expect(a.tid)   .to match(/\w+/)
    expect(a.sid)   .to match(/\w+/)

    expect(b.status).to eq(@a)
    expect(b.user).to   eq(@alice)
    expect(b.tid).to    match(/\w+/)
    expect(b.sid).to    match(/\w+/)
  end

  it "should be found by screen_name" do
    db = @db.find_by_screen_name('alice')
    expect(db.size).to eq(2)
    a,b = db

    expect(a.status).to eq(@c)
    expect(a.user)  .to eq(@alice)
    expect(a.tid)   .to match(/\w+/)
    expect(a.sid)   .to match(/\w+/)

    expect(b.status).to eq(@a)
    expect(b.user).to   eq(@alice)
    expect(b.tid).to    match(/\w+/)
    expect(b.sid).to    match(/\w+/)
  end

  it "should be found by screen_name with limit" do
    xs = @db.find_by_screen_name('alice', limit: 1)
    expect(xs.size).to eq(1)

    a,_ = xs
    expect(a.status).to eq(@c)
    expect(a.user)  .to eq(@alice)
    expect(a.tid)   .to match(/\w+/)
    expect(a.sid)   .to match(/\w+/)
  end

  it "should remove by id" do
    @db.remove_by_id 1
    expect(@db.find_by_id(1)).to be_nil
  end

  it "should have uniq tid/sid when removed" do
    old = @db.find_by_id 3
    @db.remove_by_id 3
    @db.add status: @c , user: @alice, source: :src
    new = @db.find_by_id 3

    expect(old.tid).not_to eq(new.tid)
    expect(old.sid).not_to eq(new.sid)
  end

  it "should cleanup" do
    Atig::Db::Statuses::Size = 10 unless defined? Atig::Db::Statuses::Size # hack
    Atig::Db::Statuses::Size.times do|i|
      s = status i+100, 'a', Time.utc(2010,1,5)+i+1
      @db.add status: s , user: @alice  , source: :srcB
    end
    @db.cleanup
    expect(@db.find_by_status_id(@a.id)).to eq(nil)
  end
end
