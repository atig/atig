#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/db/searches'

describe Atig::Db::Searches do
  def saved_search(id)
    search = stub "search-#{id}"
    search.stub!(:id).and_return(id)
    search
  end

  before do
    @searches = Atig::Db::Searches.new
    @foo = saved_search 0
    @bar = saved_search 1
    @baz = saved_search 2

    @searches.update [ @foo, @bar ]

    @obj = mock 'listener'
    @searches.listen{|kind,*args| @obj.send(kind,*args) }
  end

  it "should notify join" do
    @obj.should_receive(:join).with([ @baz ])
    @searches.update [ @foo, @bar, @baz ]
  end

  it "should notify part" do
    @obj.should_receive(:part).with([ @bar ])
    @searches.update [ @foo ]
  end
end
