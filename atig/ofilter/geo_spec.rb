#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/ofilter/geo'
require 'ostruct'

describe Atig::OFilter::Geo,"when disabled" do
  def filtered(text,opt={})
    geo = Atig::OFilter::Geo.new(mock("logger"),OpenStruct.new(opt))
    geo.call :status => text
  end

  it "should through" do
    filtered("hi").should == {
      :status => "hi"
    }
  end
end

describe Atig::OFilter::Geo,"when enabled" do
  def filtered(text,opt={})
    geo = Atig::OFilter::Geo.new(mock("logger"),OpenStruct.new(opt))
    geo.call :status => text
  end

  it "add lat & long" do
    filtered("hi",:ll=>"42.1,43.1").should == {
      :status => "hi",
      :lat  => 42.1,
      :long => 43.1
    }
  end
end
