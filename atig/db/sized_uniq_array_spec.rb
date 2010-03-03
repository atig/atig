#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'atig/db/sized_uniq_array'
require 'ostruct'

describe Atig::Db::SizedUniqArray do
  before do
    @array = Atig::Db::SizedUniqArray.new 3
    @item1 = OpenStruct.new 'id' => 1
    @item2 = OpenStruct.new 'id' => 2
    @item3 = OpenStruct.new 'id' => 3
    @item4 = OpenStruct.new 'id' => 4

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

  it "should not change index" do
    @array << @item1
    @array[2].should == @item3
  end
end
