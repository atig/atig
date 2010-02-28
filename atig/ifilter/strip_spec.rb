#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'atig/ifilter/strip'
require 'atig/twitter_struct'

def be_text(text)
  simple_matcher("be text") { |given| given.text.should == text }
end

def status(text)
  Atig::TwitterStruct.make('text' => text)
end

describe Atig::IFilter::Strip do
  before do
    @ifilter = Atig::IFilter::Strip.new %w(*tw*)
  end

  it "should strip *tw*" do
    @ifilter.call(status("hoge *tw*")).should be_text("hoge")
  end

  it "should strip white-space" do
    @ifilter.call(status("  hoge  ")).should be_text("hoge")
  end
end
