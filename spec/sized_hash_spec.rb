# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../spec_helper', __FILE__ )
require 'atig/sized_hash'

describe Atig::SizedHash do
  before do
    @hash = Atig::SizedHash.new 3
  end

  it "はkeyとvalueでアクセスできる" do
    @hash[:foo] = :bar
    expect(@hash[:foo]).to eq(:bar)
  end

  it "はサイズが取得できる" do
    @hash.size == 0

    @hash[:foo] = :bar
    @hash.size == 1

    @hash[:foo] = :baz
    @hash.size == 1

    @hash[:xyzzy] = :hoge
    @hash.size == 2
  end

  it "は古いのが消える" do
    ('a'..'c').each{|c| @hash[c] = 42 }

    expect(@hash.key?('a')).to be_truthy

    @hash['d'] = 42
    expect(@hash.key?('a')).to be_falsey
  end

  it "は使うたびに寿命が伸びる" do
    ('a'..'c').each{|c| @hash[c] = 42 }
    @hash['a']
    @hash['d'] = 42
    expect(@hash.key?('a')).to be_truthy
    expect(@hash.key?('b')).to be_falsey
  end
end
