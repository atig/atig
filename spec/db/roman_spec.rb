# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__ )
require 'atig/db/roman'

describe Atig::Db::Roman do
  before do
    @roman = Atig::Db::Roman.new
  end

  it "should make readble tid" do
    @roman.make(0).should == 'a'
    @roman.make(1).should == 'i'
    @roman.make(2).should == 'u'
  end
end

