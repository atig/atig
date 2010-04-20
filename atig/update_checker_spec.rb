#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'atig/update_checker'

describe Atig::UpdateChecker,'when use git version' do
  def rev(c)
    c * 40
  end

  def commit(c, mesg)
    {'id' => rev(c), 'message' => mesg}
  end

  before do
    Atig::UpdateChecker.stub!(:git?).and_return(true)
    Atig::UpdateChecker.stub!(:commits).
      and_return [
                  commit('a', 'foo'),
                  commit('b', 'bar'),
                  commit('c', 'baz'),
                  commit('d', 'xyzzy'),
                  commit('e', 'fuga'),
                 ]
  end

  it "should not do anything when use HEAD version" do
    Atig::UpdateChecker.stub!(:local_repos?).and_return true
    Atig::UpdateChecker.stub!(:server_version).and_return rev('a')

    Atig::UpdateChecker.latest.should == []
  end

  it "should notify when not use HEAD version" do
    Atig::UpdateChecker.stub!(:local_repos?).and_return false
    Atig::UpdateChecker.stub!(:server_version).and_return rev('b')

    Atig::UpdateChecker.latest.should == [ 'foo' ]
  end

  it "should notify many changes" do
    Atig::UpdateChecker.stub!(:local_repos?).and_return false
    Atig::UpdateChecker.stub!(:server_version).and_return rev('d')

    Atig::UpdateChecker.latest.should == [ 'foo', 'bar', 'baz' ]
  end

  it "should notify all changes" do
    Atig::UpdateChecker.stub!(:local_repos?).and_return false
    Atig::UpdateChecker.stub!(:server_version).and_return rev('z')

    Atig::UpdateChecker.latest.should == [ 'foo', 'bar', 'baz', 'xyzzy', 'fuga' ]
  end

end
