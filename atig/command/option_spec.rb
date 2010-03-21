#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/command/option'
require 'atig/command/command_helper'

describe Atig::Command::Option do
  include CommandHelper

  before do
    @command = init Atig::Command::Option
  end

  it "should provide option command" do
    @command.command_name.should == %w(opt opts option options)
  end
end

describe Atig::Command::Option, 'when have bool property' do
  include CommandHelper

  before do
    @command = init Atig::Command::Option
    @opts.stub!(:foo).and_return true
    @opts.stub!(:foo=){|v| @value = v }
    @channel.stub!(:notify)
  end

  it "should show the value" do
    @channel.should_receive(:notify).with("foo => true")
    call '#twitter', 'opt', %w(foo)
  end

  it "should update the value" do
    call '#twitter', 'opt', %w(foo false)
    @value.should be_false
  end
end

describe Atig::Command::Option, 'when have int property' do
  include CommandHelper

  before do
    @command = init Atig::Command::Option
    @opts.stub!(:foo).and_return 42
    @opts.stub!(:foo=){|v| @value = v }
    @channel.stub!(:notify)
  end

  it "should show the value" do
    @channel.should_receive(:notify).with("foo => 42")
    call '#twitter', 'opt', %w(foo)
  end

  it "should update the value" do
    call '#twitter', 'opt', %w(foo 42)
    @value.should == 42
  end
end

describe Atig::Command::Option, 'when have float property' do
  include CommandHelper

  before do
    @command = init Atig::Command::Option
    @opts.stub!(:foo).and_return 1.23
    @opts.stub!(:foo=){|v| @value = v }
    @channel.stub!(:notify)
  end

  it "should show the value" do
    @channel.should_receive(:notify).with("foo => 1.23")
    call '#twitter', 'opt', %w(foo)
  end

  it "should update the value" do
    call '#twitter', 'opt', %w(foo 1.24)
    @value.should == 1.24
  end
end

describe Atig::Command::Option, 'when have string property' do
  include CommandHelper

  before do
    @command = init Atig::Command::Option
    @opts.stub!(:foo).and_return "bar"
    @opts.stub!(:foo=){|v| @value = v }
    @channel.stub!(:notify)
  end

  it "should show the value" do
    @channel.should_receive(:notify).with("foo => bar")
    call '#twitter', 'opt', %w(foo)
  end

  it "should update the value" do
    call '#twitter', 'opt', %w(foo baz)
    @value.should == 'baz'
  end

  it "should update the value" do
    call '#twitter', 'opt', %w(foo blah Blah)
    @value.should == 'blah Blah'
  end
end
