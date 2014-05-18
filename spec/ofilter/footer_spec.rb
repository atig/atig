# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__ )
require 'atig/ofilter/footer'
require 'ostruct'

describe Atig::OFilter::Footer do
  before do
    @opts   = OpenStruct.new
    @filter = Atig::OFilter::Footer.new(OpenStruct.new(opts:@opts))
  end

  it "should pass through" do
    expect(@filter.call(status: 'hi')).to eq({
      status: "hi"
    })
  end

  it "should append footer" do
    @opts.footer = '*tw*'
    expect(@filter.call(status: 'hi')).to eq({
      status: "hi *tw*"
    })
  end

  it "should not append footer" do
    @opts.footer = false
    expect(@filter.call(status: 'hi')).to eq({
      status: "hi"
    })
  end
end
