# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__ )
require 'atig/ofilter/footer'
require 'ostruct'

describe Atig::OFilter::Footer do
  before do
    @opts   = OpenStruct.new
    @filter = Atig::OFilter::Footer.new(OpenStruct.new(:opts=>@opts))
  end

  it "should pass through" do
    @filter.call(:status => 'hi').should == {
      :status => "hi"
    }
  end

  it "should append footer" do
    @opts.footer = '*tw*'
    @filter.call(:status => 'hi').should == {
      :status => "hi *tw*"
    }
  end

  it "should not append footer" do
    @opts.footer = false
    @filter.call(:status => 'hi').should == {
      :status => "hi"
    }
  end
end
