# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__ )
require 'atig/ifilter/retweet'
require 'atig/twitter_struct'

describe Atig::IFilter::Retweet do
  def filtered(text, opt={})
    Atig::IFilter::Retweet.call status(text, opt)
  end

  before do
    @rt = Atig::IFilter::Retweet::Prefix
  end

  it "should throw normal status" do
    expect(filtered("hello")).to be_text("hello")
  end

  it "should prefix RT for Retweet" do
    expect(filtered("RT: hello...",
             'retweeted_status'=>{ 'text' => 'hello',
               'user' => {
                 'screen_name' => 'mzp'
               } })).
      to be_text("#{@rt}RT @mzp: hello")
  end
end
