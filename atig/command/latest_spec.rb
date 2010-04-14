#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/command/latest'
require 'atig/command/command_helper'

describe Atig::Command::Latest do
  include CommandHelper

  def rev(c)
    c * 40
  end

  before do
    @command = init Atig::Command::Latest
    @command.stub!(:commits).and_return [
                                         {'id' => rev('a'), 'message' => 'foo'},
                                         {'id' => rev('b'), 'message' => 'bar'},
                                         {'id' => rev('c'), 'message' => 'baz'},
                                         {'id' => rev('d'), 'message' => 'xyzzy'},
                                         {'id' => rev('e'), 'message' => 'fuga'}
                                        ]
  end

  it "should not notify" do
    @command.stub!(:local_repos?).and_return true
    @command.stub!(:server_version).and_return rev('a')

    call '#twitter', "latest", []
  end

  it "should not notify changes" do
    @command.stub!(:local_repos?).and_return false
    @command.stub!(:server_version).and_return rev('b')

    @channel.should_receive(:notify).with("\002New version is available.\017 run 'git pull'.")
    @channel.should_receive(:notify).with("  \002foo\017")

    call '#twitter', "latest", []
  end

  it "should not notify 3 changes" do
    @command.stub!(:local_repos?).and_return false
    @command.stub!(:server_version).and_return rev('e')

    @channel.should_receive(:notify).with("\002New version is available.\017 run 'git pull'.")
    @channel.should_receive(:notify).with("  \002foo\017")
    @channel.should_receive(:notify).with("  \002bar\017")
    @channel.should_receive(:notify).with("  \002baz\017")
    @channel.should_receive(:notify).with("  ... and more. check it: http://bit.ly/79d33W")

    call '#twitter', "latest", []
  end
end
