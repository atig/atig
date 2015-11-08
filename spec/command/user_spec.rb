# -*- mode:ruby; coding:utf-8 -*-

require 'atig/command/user'

describe Atig::Command::User do
  include CommandHelper
  before do
    @command = init Atig::Command::User
  end

  it "should have '/me status' name" do
    expect(@gateway.names).to eq(['user', 'u'])
  end

  it "should" do
    foo = entry user(1,'mzp'),status('foo')
    bar = entry user(1,'mzp'),status('bar')
    baz = entry user(1,'mzp'),status('baz')
    expect(@api).
      to receive(:get).
      with('statuses/user_timeline',:count=>20,:screen_name=>'mzp').
      and_return([foo, bar, baz])
    expect(@statuses).to receive(:add).with(any_args).at_least(3)
    expect(@statuses).
      to receive(:find_by_screen_name).
      with('mzp',:limit=>20).
      and_return([foo, bar, baz])
    expect(@channel).to receive(:message).with(anything, Net::IRC::Constants::NOTICE).at_least(3)
    call "#twitter","user",%w(mzp)
  end

  it "should get specified statuses" do
    foo = entry user(1,'mzp'),status('foo')
    bar = entry user(1,'mzp'),status('bar')
    baz = entry user(1,'mzp'),status('baz')
    expect(@api).
      to receive(:get).
      with('statuses/user_timeline',:count=>200,:screen_name=>'mzp').
      and_return([foo, bar, baz])
    expect(@statuses).to receive(:add).with(any_args).at_least(3)
    expect(@statuses).
      to receive(:find_by_screen_name).
      with('mzp',:limit=>200).
      and_return([foo, bar, baz])
    expect(@channel).to receive(:message).with(anything, Net::IRC::Constants::NOTICE).at_least(3)
    call "#twitter","user",%w(mzp 200)
  end
end
