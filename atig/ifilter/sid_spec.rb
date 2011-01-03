#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require File.expand_path( '../spec_helper', File.dirname(__FILE__) )
require 'atig/ifilter/xid'
require 'atig/twitter_struct'

describe Atig::IFilter::Sid, "when disable tid" do
  def filtered(text)
    ifilter = Atig::IFilter::Sid.new(OpenStruct.new(:log=>mock('log'),
                                                    :opts=>OpenStruct.new))
    ifilter.call status(text,'sid'=>1)
  end

  it "should through text" do
    filtered("hello").should be_text("hello")
  end
end

describe Atig::IFilter::Sid, "when enable tid" do
  def filtered(text)
    ifilter = Atig::IFilter::Sid.new(OpenStruct.new(:log=>mock('log'),
                                                    :opts=>OpenStruct.new(:sid=>true)))
    ifilter.call status(text,'sid'=>1)
  end

  it "should append sid" do
    filtered("hello").should be_text("hello \x0310[1]\x0F")
  end
end
