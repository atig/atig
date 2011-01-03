#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require File.expand_path( 'spec_helper', File.dirname(__FILE__) )
require 'atig/sized_hash'

describe Atig::SizedHash do
  before do
    @hash = Atig::SizedHash.new 3
  end

  it "はkeyとvalueでアクセスできる" do
    @hash[:foo] = :bar
    @hash[:foo].should == :bar
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

    @hash.key?('a').should be_true

    @hash['d'] = 42
    @hash.key?('a').should be_false
  end

  it "は使うたびに寿命が伸びる" do
    ('a'..'c').each{|c| @hash[c] = 42 }
    @hash['a']
    @hash['d'] = 42
    @hash.key?('a').should be_true
    @hash.key?('b').should be_false
  end
end
