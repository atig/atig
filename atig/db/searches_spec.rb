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

    @called = Hash.new{|hash,key| hash[key] = [] }
    @searches.listen{|kind, searches| @called[kind] << searches }
  end

  it "should notify join" do
    @searches.update [ @foo, @bar, @baz ]
    @called[:join].should == [ @baz ]
    @called[:part].should == [ ]
  end

  it "should notify part" do
    @searches.update [ @bar ]
    @called[:join].should == [ ]
    @called[:part].should == [ @foo ]
  end
end
