#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/ifilter/tid'
require 'atig/twitter_struct'
require 'atig/spec_helper'

describe Atig::IFilter::Tid, "when disable tid" do
  def filtered(text)
    ifilter = Atig::IFilter::Tid.new(OpenStruct.new(:log=>mock('log'),
                                                    :opts=>OpenStruct.new))
    ifilter.call status(text,'tid'=>1)
  end

  it "should through text" do
    filtered("hello").should be_text("hello")
  end
end

describe Atig::IFilter::Tid, "when enable tid" do
  def filtered(text)
    ifilter = Atig::IFilter::Tid.new(OpenStruct.new(:log=>mock('log'),
                                                    :opts=>OpenStruct.new(:tid=>true)))
    ifilter.call status(text,'tid'=>1)
  end

  it "should append tid" do
    filtered("hello").should be_text("hello \x0310[1]\x0F")
  end
end
