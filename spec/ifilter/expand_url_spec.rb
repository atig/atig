# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__ )
require 'atig/ifilter/expand_url'
require 'atig/twitter_struct'

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

describe Atig::IFilter::ExpandUrl, "when has urls entities" do
  def filtered(text, opts)
    context = OpenStruct.new(
                             :log => mock('log'),
                             :opts => OpenStruct.new)
    ifilter = Atig::IFilter::ExpandUrl.new(context)
    ifilter.call status(text, opts)
  end

  it "should expand t.co" do
    opts = {
      "entities" => {
        "urls" => [{
          "url" => "http://t.co/1Vyoux4kB8",
          "expanded_url" => "http://example.com/"
        }]
      }
    }
    filtered("http://t.co/1Vyoux4kB8", opts).should be_text("http://example.com/")
  end
end
