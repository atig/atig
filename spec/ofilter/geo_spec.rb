# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__ )
require 'atig/ofilter/geo'
require 'ostruct'

describe Atig::OFilter::Geo,"when disabled" do
  def filtered(text,opt={})
    geo = Atig::OFilter::Geo.new(OpenStruct.new(:opts=>OpenStruct.new(opt)))
    geo.call :status => text
  end

  it "should through" do
    expect(filtered("hi")).to eq({
      :status => "hi"
    })
  end
end

describe Atig::OFilter::Geo,"when enabled" do
  def filtered(text,opt={})
    geo = Atig::OFilter::Geo.new(OpenStruct.new(:opts=>OpenStruct.new(opt)))
    geo.call :status => text
  end

  it "add lat & long" do
    expect(filtered("hi",:ll=>"42.1,43.1")).to eq({
      :status => "hi",
      :lat  => 42.1,
      :long => 43.1
    })
  end
end
