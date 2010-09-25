#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/ifilter/retweet_time'
require 'atig/twitter_struct'
require 'atig/spec_helper'

describe Atig::IFilter::RetweetTime do
  def filtered(text, opt={})
    Atig::IFilter::RetweetTime.call status(text, opt)
  end

  it "should throw normal status" do
    filtered("hello").should be_text("hello")
  end

  it "should prefix RT for Retweet" do
    filtered("RT @mzp: hello",
             'retweeted_status'=>{ 'text' => 'hello',
               'created_at' => 'Sat Sep 25 14:33:19 +0000 2010',
               'user' => {
                 'screen_name' => 'mzp'
               } }).
      should be_text("#{@rt}RT @mzp: hello \x0310[2010-09-25 23:33]\x0F")
  end
end
