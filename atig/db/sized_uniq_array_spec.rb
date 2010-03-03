#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'atig/db/sized_uniq_array'
require 'ostruct'

describe Atig::Db::SizedUniqArray do
  def item(id)
    item = mock 'Item'
    item.should_receive(:id).and_return id
    item
  end

  before do
    @array = Atig::Db::SizedUniqArray.new 3
    @item1 = item 1
    @item2 = item 2
    @item3 = item 3
    @item4 = item 4

    @array << @item1
    @array << @item2
    @array << @item3
  end

  it "should include items" do
    @array.to_a.should == [ @item1, @item2, @item3 ]
  end

  it "should rorate array" do
    @array << @item4
    @array.to_a.should == [ @item2, @item3, @item4 ]
  end

  it "should not have duplicate element" do
    @array << item 1
    @array.to_a.should == [ @item1, @item2, @item3 ]
  end

  it "should be accesible by index" do
    @array[0].should == @item1
    @array[1].should == @item2
    @array[2].should == @item3
  end

  it "should not change index" do
    @array << @item4
    @array[0].should == @item4
    @array[1].should == @item2
    @array[2].should == @item3
  end

  it "should return index when add element" do
    (@array << @item4).should == 0
    (@array << @item3).should == nil
  end
end
