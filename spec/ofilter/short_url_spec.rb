# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__ )
require 'atig/ofilter/short_url'
require 'ostruct'

describe Atig::OFilter::ShortUrl,"when no-login bitly" do
  before do
    logger = double('Logger')
    bitly =  double("Bitly")
    allow(bitly).to receive(:shorten){|s|
      "[#{s}]"
    }
    expect(Atig::Bitly).to receive(:no_login).with(logger).and_return(bitly)
    @ofilter = Atig::OFilter::ShortUrl.new(OpenStruct.new(:log=>logger, :opts=>OpenStruct.new('bitlify'=>true)))
  end

  it "should shorten url by bitly" do
    expect(@ofilter.call({:status => "this is http://example.com/a http://example.com/b"})).to eq({
      :status => "this is [http://example.com/a] [http://example.com/b]"
    })
  end
end

describe Atig::OFilter::ShortUrl,"when no-login bitly with size" do
  before do
    logger = double('Logger')
    bitly =  double("Bitly")
    allow(bitly).to receive(:shorten){|s|
      "[#{s}]"
    }
    expect(Atig::Bitly).to receive(:no_login).with(logger).and_return(bitly)
    @ofilter = Atig::OFilter::ShortUrl.new(OpenStruct.new(:log=>logger, :opts=>OpenStruct.new('bitlify'=>13)))
  end

  it "should only shorten large url" do
    expect(@ofilter.call({:status => "this is http://example.com/a http://a.com"})).to eq({
      :status => "this is [http://example.com/a] http://a.com"
    })
  end
end

describe Atig::OFilter::ShortUrl,"when login bitly" do
  before do
    logger = double('Logger')
    bitly =  double("Bitly")
    allow(bitly).to receive(:shorten){|s|
      "[#{s}]"
    }
    expect(Atig::Bitly).to receive(:login).with(logger,"username","api_key").and_return(bitly)
    @ofilter = Atig::OFilter::ShortUrl.new(OpenStruct.new(:log=>logger, :opts=>OpenStruct.new('bitlify'=>'username:api_key')))
  end

  it "should only shorten large url" do
    expect(@ofilter.call({:status => "this is http://example.com/a http://example.com/b"})).to eq({
      :status => "this is [http://example.com/a] [http://example.com/b]"
    })
  end
end

describe Atig::OFilter::ShortUrl,"when login bitly with size" do
  before do
    logger = double('Logger')
    bitly =  double("Bitly")
    allow(bitly).to receive(:shorten){|s|
      "[#{s}]"
    }
    expect(Atig::Bitly).to receive(:login).with(logger,"username","api_key").and_return(bitly)
    @ofilter = Atig::OFilter::ShortUrl.new(OpenStruct.new(:log=>logger, :opts=>OpenStruct.new('bitlify'=>'username:api_key:13')))
  end

  it "should only shorten large url" do
    expect(@ofilter.call({:status => "this is http://example.com/a http://a.com"})).to eq({
      :status => "this is [http://example.com/a] http://a.com"
    })
  end
end

describe Atig::OFilter::ShortUrl,"when nop" do
  before do
    logger = double('Logger')

    @ofilter = Atig::OFilter::ShortUrl.new(OpenStruct.new(:log=>logger, :opts=>OpenStruct.new()))
  end

  it "should only not do anything" do
    expect(@ofilter.call({:status => "this is http://example.com/a http://a.com"})).to eq({
      :status => "this is http://example.com/a http://a.com"
    })
  end
end
