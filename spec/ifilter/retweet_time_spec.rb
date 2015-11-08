# -*- mode:ruby; coding:utf-8 -*-

require 'atig/ifilter/retweet_time'
require 'atig/twitter_struct'

describe Atig::IFilter::RetweetTime do
  def filtered(text, opt={})
    Atig::IFilter::RetweetTime.call status(text, opt)
  end

  it "should throw normal status" do
    expect(filtered("hello")).to be_text("hello")
  end

  it "should prefix RT for Retweet" do
    expect(filtered("RT @mzp: hello",
             'retweeted_status'=>{ 'text' => 'hello',
               'created_at' => 'Sat Sep 25 14:33:19 +0000 2010',
               'user' => {
                 'screen_name' => 'mzp'
               } })).
      to be_text("#{@rt}RT @mzp: hello \x0310[2010-09-25 14:33]\x0F")
  end
end
