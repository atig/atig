#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

describe Atig::Option do
  before do
    @opt = Atig::Option.parse 'a b=1 c=1.2 d=foo'
  end

  it "should have bool property" do
    @opt.a.should be_true
  end

  it "should have int property" do
    @opt.b.should == 1
  end

  it "should have float property" do
    @opt.c.should == 1.2
  end

  it "should have string property" do
    @opt.d.should == 'foo'
  end

  it "should not have other property" do
    @opt.e.should == nil
  end

  it "should update the value" do
    @opt.a = false
    @opt.a.should be_false
  end

  it "should be accessed by [name]" do
    @opt[:a].should be_true
    @opt['a'].should be_true
  end

  it "should be updated by [name]=" do
    @opt[:a] = false

    @opt.a.should be_false
    @opt[:a].should be_false
    @opt['a'].should be_false
  end

  it "should be updated by [name]=" do
    @opt['a'] = false

    @opt.a.should be_false
    @opt[:a].should be_false
    @opt['a'].should be_false
  end

  it "should be created by [name]=" do
    @opt['e'] = false

    @opt.e.should be_false
    @opt[:e].should be_false
    @opt['e'].should be_false
  end

  it "should be access to id" do
    @opt.id.should be_nil
    @opt.id = 1
    @opt.id.should == 1
  end

  it "should have default value" do
    @opt.api_base.should == 'https://api.twitter.com/1/'
  end

  it "should list up all fields" do
    @opt.fields.map{|x| x.to_s }.sort.should == %w(api_base stream_api_base a b c d).sort

    @opt.e = 1
    @opt.fields.map{|x| x.to_s }.sort.should == %w(api_base stream_api_base a b c d e).sort
  end
end

describe Atig::Option,'with not default value' do
  before do
    @opt = Atig::Option.parse 'hoge api_base=twitter.com'
  end

  it "should be specified value" do
    @opt.api_base.should == 'twitter.com'
  end
end
