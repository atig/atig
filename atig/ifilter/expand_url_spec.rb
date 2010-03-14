#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/ifilter/expand_url'
require 'atig/twitter_struct'
require 'atig/spec_helper'

class Atig::IFilter::ExpandUrl
  def resolve_http_redirect(uri); "[#{uri}]" end
end

describe Atig::IFilter::ExpandUrl, "when disable whole url" do
  def filtered(text)
    ifilter = Atig::IFilter::ExpandUrl.new OpenStruct.new(:log=>mock('log'),:opts=>OpenStruct.new)
    ifilter.call status(text)
  end

  it "should expand bit.ly" do
    filtered("This is http://bit.ly/hoge").should be_text("This is [http://bit.ly/hoge]")
  end

  it "should through other url" do
    filtered("http://example.com").should be_text("http://example.com")
  end
end

describe Atig::IFilter::ExpandUrl, "when enable whole url" do
  def filtered(text)
    context = OpenStruct.new(
                             :log  => mock('log'),
                             :opts => OpenStruct.new(:untiny_whole_urls=>true))
    ifilter = Atig::IFilter::ExpandUrl.new(context)
    ifilter.call status(text)
  end

  it "should expand bit.ly" do
    filtered("This is http://bit.ly/hoge").should be_text("This is [http://bit.ly/hoge]")
  end

  it "should expand other url" do
    filtered("http://example.com").should be_text("[http://example.com]")
    filtered("https://example.com").should be_text("[https://example.com]")
  end
end

