# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__ )
require 'atig/ofilter/escape_url'

class Atig::OFilter::EscapeUrl
  def exist_uri?(_); true end
end

describe Atig::OFilter::EscapeUrl do
  before do
    @logger = double('Logger')
    expect(@logger).to receive(:info).at_most(:once)
    expect(@logger).to receive(:error).at_most(:once)
    expect(@logger).to receive(:debug).at_most(:once)
  end

  def filtered(text,opt={})
    esc = Atig::OFilter::EscapeUrl.new(OpenStruct.new(:log=>@logger,:opts=>nil))
    esc.call :status => text
  end

  it "through normal url" do
    expect(filtered("http://example.com")).to eq({ :status => "http://example.com"})
  end

  it "escape only url" do
    expect(filtered("あああ http://example.com/あああ")).to eq({ :status => "あああ http://example.com/%E3%81%82%E3%81%82%E3%81%82" })
  end
end

if defined? ::Punycode then
  describe Atig::OFilter::EscapeUrl,"when punycode is enabled" do
    before do
      @logger = double('Logger')
      expect(@logger).to receive(:info).at_most(:once)
      expect(@logger).to receive(:error).at_most(:once)
      expect(@logger).to receive(:debug).at_most(:once)
    end

    def filtered(text,opt={})
      esc = Atig::OFilter::EscapeUrl.new(OpenStruct.new(:log=>@logger,:opts=>nil))
      esc.call :status => text
    end

    it "escape international URL" do
      expect(filtered("http://あああ.com")).to eq({:status => "http://xn--l8jaa.com" })
    end
  end
end
