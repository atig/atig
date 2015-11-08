# -*- mode:ruby; coding:utf-8 -*-

require 'atig/ifilter/sanitize'
require 'atig/twitter_struct'

describe Atig::IFilter::Sanitize do
  def filtered(text)
    Atig::IFilter::Sanitize.call status(text)
  end

  it "should convert escape html" do
    expect(filtered("&lt; &gt; &quot;")).to be_text("< > \"")
  end

  it "should convert whitespace" do
    expect(filtered("\r\n")).to be_text(" ")
    expect(filtered("\r")).to be_text(" ")
    expect(filtered("\n")).to be_text(" ")
  end

  it "should delete \\000\\001 sequence" do
    expect(filtered("\000\001")).to be_text("")
  end
end
