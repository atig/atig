#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/ifilter/utf7'
require 'atig/twitter_struct'
require 'atig/spec_helper'

describe Atig::IFilter::Utf7 do
  def filtered(text)
    logger = mock('logger').should_receive(:error).at_most(:once)
    ifilter = Atig::IFilter::Utf7.new logger
    ifilter.call status(text)
  end

  it "should be used in Iconv" do
    defined?(::Iconv).should be_true
  end

  it "should through ASCII" do
    filtered("hello").should be_text("hello")
  end

  it "should decode +sequence" do
    filtered("1 +- 1 = 2").should be_text("1 + 1 = 2")
  end

  it "should decode pound sign" do
    filtered("+AKM-1").should be_text("£1")
  end
end
