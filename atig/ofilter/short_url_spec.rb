#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
#
require 'atig/ofilter/short_url'
require 'ostruct'

describe Atig::OFilter::ShortUrl,"when no-login bitly" do
  before do
    logger = mock('Logger')
    bitly =  mock("Bitly")
    bitly.stub!(:shorten).and_return{|s|
      "[#{s}]"
    }
    Atig::Bitly.should_receive(:no_login).with(logger).and_return(bitly)
    @ofilter = Atig::OFilter::ShortUrl.new logger,OpenStruct.new('bitlify'=>true)
  end

  it "should shorten url by bitly" do
    @ofilter.call({:status => "this is http://example.com/a http://example.com/b"}).should == {
      :status => "this is [http://example.com/a] [http://example.com/b]"
    }
  end
end

describe Atig::OFilter::ShortUrl,"when no-login bitly with size" do
  before do
    logger = mock('Logger')
    bitly =  mock("Bitly")
    bitly.stub!(:shorten).and_return{|s|
      "[#{s}]"
    }
    Atig::Bitly.should_receive(:no_login).with(logger).and_return(bitly)
    @ofilter = Atig::OFilter::ShortUrl.new logger,OpenStruct.new('bitlify'=>13)
  end

  it "should only shorten large url" do
    @ofilter.call({:status => "this is http://example.com/a http://a.com"}).should == {
      :status => "this is [http://example.com/a] http://a.com"
    }
  end
end

describe Atig::OFilter::ShortUrl,"when login bitly" do
  before do
    logger = mock('Logger')
    bitly =  mock("Bitly")
    bitly.stub!(:shorten).and_return{|s|
      "[#{s}]"
    }
    Atig::Bitly.should_receive(:login).with(logger,"username","api_key").and_return(bitly)
    @ofilter = Atig::OFilter::ShortUrl.new logger,OpenStruct.new('bitlify'=>"username:api_key")
  end

  it "should only shorten large url" do
    @ofilter.call({:status => "this is http://example.com/a http://example.com/b"}).should == {
      :status => "this is [http://example.com/a] [http://example.com/b]"
    }
  end
end

describe Atig::OFilter::ShortUrl,"when login bitly with size" do
  before do
    logger = mock('Logger')
    bitly =  mock("Bitly")
    bitly.stub!(:shorten).and_return{|s|
      "[#{s}]"
    }
    Atig::Bitly.should_receive(:login).with(logger,"username","api_key").and_return(bitly)
    @ofilter = Atig::OFilter::ShortUrl.new logger,OpenStruct.new('bitlify'=>"username:api_key:13")
  end

  it "should only shorten large url" do
    @ofilter.call({:status => "this is http://example.com/a http://a.com"}).should == {
      :status => "this is [http://example.com/a] http://a.com"
    }
  end
end

describe Atig::OFilter::ShortUrl,"when unu bitly" do
  before do
    logger = mock('Logger')
    unu =  mock("Unu")
    unu.stub!(:shorten).and_return{|s|
      "[#{s}]"
    }
    Atig::Unu.should_receive(:new).with(logger).and_return(unu)
    @ofilter = Atig::OFilter::ShortUrl.new logger,OpenStruct.new('unuify'=>true)
  end

  it "should shorten url by unu" do
    @ofilter.call({:status => "this is http://example.com/a http://example.com/b"}).should == {
      :status => "this is [http://example.com/a] [http://example.com/b]"
    }
  end
end

describe Atig::OFilter::ShortUrl,"when no-login unu with size" do
  before do
    logger = mock('Logger')
    unu =  mock("Unu")
    unu.stub!(:shorten).and_return{|s|
      "[#{s}]"
    }
    Atig::Unu.should_receive(:new).with(logger).and_return(unu)
    @ofilter = Atig::OFilter::ShortUrl.new logger,OpenStruct.new('unuify'=>13)
  end

  it "should only shorten large url" do
    @ofilter.call({:status => "this is http://example.com/a http://a.com"}).should == {
      :status => "this is [http://example.com/a] http://a.com"
    }
  end
end

describe Atig::OFilter::ShortUrl,"when nop" do
  before do
    logger = mock('Logger')

    @ofilter = Atig::OFilter::ShortUrl.new logger,OpenStruct.new
  end

  it "should only not do anything" do
    @ofilter.call({:status => "this is http://example.com/a http://a.com"}).should == {
      :status => "this is http://example.com/a http://a.com"
    }
  end
end
