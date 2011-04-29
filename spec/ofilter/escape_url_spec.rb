# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__ )
require 'atig/ofilter/escape_url'

class Atig::OFilter::EscapeUrl
  def exist_uri?(_); true end
end

describe Atig::OFilter::EscapeUrl do
  before do
    @logger = mock('Logger')
    @logger.should_receive(:info).at_most(:once)
    @logger.should_receive(:error).at_most(:once)
    @logger.should_receive(:debug).at_most(:once)
  end

  def filtered(text,opt={})
    esc = Atig::OFilter::EscapeUrl.new(OpenStruct.new(:log=>@logger,:opts=>nil))
    esc.call :status => text
  end

  it "through normal url" do
    filtered("http://example.com").should == { :status => "http://example.com"}
  end

  it "escape only url" do
    filtered("あああ http://example.com/あああ").should == { :status => "あああ http://example.com/%E3%81%82%E3%81%82%E3%81%82" }
  end
end

if defined? ::Punycode then
  describe Atig::OFilter::EscapeUrl,"when punycode is enabled" do
    before do
      @logger = mock('Logger')
      @logger.should_receive(:info).at_most(:once)
      @logger.should_receive(:error).at_most(:once)
      @logger.should_receive(:debug).at_most(:once)
    end

    def filtered(text,opt={})
      esc = Atig::OFilter::EscapeUrl.new(OpenStruct.new(:log=>@logger,:opts=>nil))
      esc.call :status => text
    end

    it "escape international URL" do
      filtered("http://あああ.com").should == {:status => "http://xn--l8jaa.com" }
    end
  end
end
