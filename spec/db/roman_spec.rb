# -*- mode:ruby; coding:utf-8 -*-

require 'atig/db/roman'

describe Atig::Db::Roman do
  before do
    @roman = Atig::Db::Roman.new
  end

  it "should make readble tid" do
    expect(@roman.make(0)).to eq('a')
    expect(@roman.make(1)).to eq('i')
    expect(@roman.make(2)).to eq('u')
  end
end
