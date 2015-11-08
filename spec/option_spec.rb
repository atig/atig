# -*- mode:ruby; coding:utf-8 -*-

require 'atig/option'

describe Atig::Option do
  before do
    @opt = Atig::Option.parse 'a b=1 c=1.2 d=foo'
  end

  it "should have bool property" do
    expect(@opt.a).to be_truthy
  end

  it "should have int property" do
    expect(@opt.b).to eq(1)
  end

  it "should have float property" do
    expect(@opt.c).to eq(1.2)
  end

  it "should have string property" do
    expect(@opt.d).to eq('foo')
  end

  it "should not have other property" do
    expect(@opt.e).to eq(nil)
  end

  it "should update the value" do
    @opt.a = false
    expect(@opt.a).to be_falsey
  end

  it "should be accessed by [name]" do
    expect(@opt[:a]).to be_truthy
    expect(@opt['a']).to be_truthy
  end

  it "should be updated by [name]=" do
    @opt[:a] = false

    expect(@opt.a).to be_falsey
    expect(@opt[:a]).to be_falsey
    expect(@opt['a']).to be_falsey
  end

  it "should be updated by [name]=" do
    @opt['a'] = false

    expect(@opt.a).to be_falsey
    expect(@opt[:a]).to be_falsey
    expect(@opt['a']).to be_falsey
  end

  it "should be created by [name]=" do
    @opt['e'] = false

    expect(@opt.e).to be_falsey
    expect(@opt[:e]).to be_falsey
    expect(@opt['e']).to be_falsey
  end

  it "should be access to id" do
    expect(@opt.id).to be_nil
    @opt.id = 1
    expect(@opt.id).to eq(1)
  end

  it "should have default value" do
    expect(@opt.api_base).to eq('https://api.twitter.com/1.1/')
  end

  it "should list up all fields" do
    expect(@opt.fields.map{|x| x.to_s }.sort).to eq(%w(api_base stream_api_base search_api_base a b c d).sort)

    @opt.e = 1
    expect(@opt.fields.map{|x| x.to_s }.sort).to eq(%w(api_base search_api_base stream_api_base a b c d e).sort)
  end
end

describe Atig::Option,'with not default value' do
  before do
    @opt = Atig::Option.parse 'hoge api_base=twitter.com'
  end

  it "should be specified value" do
    expect(@opt.api_base).to eq('twitter.com')
  end
end
