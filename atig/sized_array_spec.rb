#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'ostruct'
require 'atig/sized_array'
require 'atig/twitter_struct'

describe Atig::SizedArray do
  before do
    @array = Atig::SizedArray.new 3
    @item1 = Atig::TwitterStruct.make 'id' => 1
    @item2 = Atig::TwitterStruct.make 'id' => 2
    @item3 = Atig::TwitterStruct.make 'id' => 3
    @item4 = Atig::TwitterStruct.make 'id' => 4

    @array << @item1
    @array << @item2
    @array << @item3
    @array << @item4
  end

  it "should have 3 elements" do
    @array.include?(@item1).should be_false
    @array.include?(@item2).should be_true
    @array.include?(@item3).should be_true
    @array.include?(@item4).should be_true
  end

  it "should not move index" do
    i = @array.index @item3
    @array << @item1
    j = @array.index @item3
    i.should == j
  end

  it "should not change tid" do
    @array << @item1
    @array[@item3.tid].should == @item3
  end

  it "should genarte readable-tid" do
    @item1.tid.should == "a"
    @item2.tid.should == "i"
    @item3.tid.should == "u"
    @item4.tid.should == "a"
  end
end
