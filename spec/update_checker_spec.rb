# -*- mode:ruby; coding:utf-8 -*-

require 'atig/update_checker'

describe Atig::UpdateChecker,'when use git version' do
  def rev(c)
    c * 40
  end

  def commit(c, mesg)
    {'sha' => rev(c), 'commit' => {'message' => mesg}}
  end

  before do
    allow(Atig::UpdateChecker).to receive(:git?).and_return(true)
    allow(Atig::UpdateChecker).to receive(:commits).
      and_return [
                  commit('a', 'foo'),
                  commit('b', 'bar'),
                  commit('c', 'baz'),
                  commit('d', 'xyzzy'),
                  commit('e', 'fuga'),
                 ]
  end

  it "should not do anything when use HEAD version" do
    allow(Atig::UpdateChecker).to receive(:local_repos?).and_return true
    allow(Atig::UpdateChecker).to receive(:server_version).and_return rev('a')

    expect(Atig::UpdateChecker.latest).to eq([])
  end

  it "should notify when not use HEAD version" do
    allow(Atig::UpdateChecker).to receive(:local_repos?).and_return false
    allow(Atig::UpdateChecker).to receive(:server_version).and_return rev('b')

    expect(Atig::UpdateChecker.latest).to eq([ 'foo' ])
  end

  it "should notify many changes" do
    allow(Atig::UpdateChecker).to receive(:local_repos?).and_return false
    allow(Atig::UpdateChecker).to receive(:server_version).and_return rev('d')

    expect(Atig::UpdateChecker.latest).to eq([ 'foo', 'bar', 'baz' ])
  end

  it "should notify all changes" do
    allow(Atig::UpdateChecker).to receive(:local_repos?).and_return false
    allow(Atig::UpdateChecker).to receive(:server_version).and_return rev('z')

    expect(Atig::UpdateChecker.latest).to eq([ 'foo', 'bar', 'baz', 'xyzzy', 'fuga' ])
  end

end
