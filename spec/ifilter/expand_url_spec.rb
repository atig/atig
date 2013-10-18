# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__ )
require 'atig/ifilter/expand_url'
require 'atig/twitter_struct'

class Atig::IFilter::ExpandUrl
  def resolve_http_redirect(uri); "[#{uri}]" end
end

describe Atig::IFilter::ExpandUrl, "when disable whole url" do
  def filtered(text)
    ifilter = Atig::IFilter::ExpandUrl.new OpenStruct.new(:log=>double('log'),:opts=>OpenStruct.new)
    ifilter.call status(text)
  end

  it "should expand bit.ly" do
    filtered("This is http://bit.ly/hoge").should be_text("This is [http://bit.ly/hoge]")
    filtered("This is http://bitly.com/hoge").should be_text("This is [http://bitly.com/hoge]")
  end

  it "should expand htn.to" do
    filtered("This is http://htn.to/TZdkXg").should be_text("This is [http://htn.to/TZdkXg]")
    filtered("This is http://htnnto/TZdkXg").should be_text("This is http://htnnto/TZdkXg")
  end

  it "should expand tmblr.co" do
    filtered("This is http://tmblr.co/Z0rNbyxhxUK5").should be_text("This is [http://tmblr.co/Z0rNbyxhxUK5]")
  end

  it "should expand nico.ms" do
    filtered("This is http://nico.ms/sm11870888").should be_text("This is [http://nico.ms/sm11870888]")
  end

  it "should through other url" do
    filtered("http://example.com").should be_text("http://example.com")
  end
end

describe Atig::IFilter::ExpandUrl, "when enable whole url" do
  def filtered(text)
    context = OpenStruct.new(
                             :log  => double('log'),
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
                             :log => double('log'),
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
        }, {
          "url" => "http://t.co/V1441ye6g2",
          "expanded_url" => "http://example.org/"
        }]
      }
    }
    filtered("http://t.co/1Vyoux4kB8", opts).should be_text("http://example.com/")
    filtered("http://t.co/1Vyoux4kB8 http://t.co/V1441ye6g2", opts).should
      be_text("http://example.com/ http://expmaple.org/")
  end

  it "should expand recursive shorten URL" do
    opts = {
      "entities" => {
        "urls" => [{
          "url" => "http://t.co/h8sqL5ZMuz",
          "expanded_url" => "http://bit.ly/1LM4fW"
        }]
      }
    }
    filtered("http://t.co/h8sqL5ZMuz", opts).should be_text("[http://bit.ly/1LM4fW]")
  end
end
