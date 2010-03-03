#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'atig/db/roman'

describe Atig::Db::Roman do
  before do
    @roman = Atig::Db::Roman.new
  end

  it "should make readble tid" do
    @roman.make(0).should == 'a'
    @roman.make(1).should == 'i'
    @roman.make(2).should == 'u'
  end

  it "should reverse tid" do
    tid = @roman.make(42)
    @roman[tid].should == 42
  end
end

