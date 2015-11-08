# -*- mode:ruby; coding:utf-8 -*-

require 'atig/db/sized_uniq_array'
require 'ostruct'

describe Atig::Db::SizedUniqArray do
  def item(id)
    item = double "Item-#{id}"
    allow(item).to receive(:id).and_return id
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
    expect(@array.to_a).to eq([ @item1, @item2, @item3 ])
  end

  it "should rorate array" do
    @array << @item4
    expect(@array.to_a).to eq([ @item2, @item3, @item4 ])
  end

  it "should have reverse_each" do
    xs = []
    @array.reverse_each {|x| xs << x }
    expect(xs).to eq([ @item3, @item2, @item1 ])
  end

  it "should not have duplicate element" do
    @array << item(1)
    expect(@array.to_a).to eq([ @item1, @item2, @item3 ])
  end

  it "should be accesible by index" do
    expect(@array[0]).to eq(@item1)
    expect(@array[1]).to eq(@item2)
    expect(@array[2]).to eq(@item3)
  end

  it "should not change index" do
    @array << @item4
    expect(@array[0]).to eq(@item4)
    expect(@array[1]).to eq(@item2)
    expect(@array[2]).to eq(@item3)
  end

  it "should return index when add element" do
    expect(@array << @item4).to eq(0)
    expect(@array << @item3).to eq(nil)
  end
end
