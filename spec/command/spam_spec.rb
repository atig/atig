# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__ )
require 'atig/command/spam'

describe Atig::Command::Spam do
  include CommandHelper
  before do
    @command = init Atig::Command::Spam
  end

  it "はspamコマンドを提供する" do
    expect(@gateway.names).to eq(%w(spam SPAM))
  end

  it "は指定されたscreen_nameを通報する" do
    user = user(1,'examplespammer')
    expect(@api).
      to receive(:post).
      with('report_spam',:screen_name=> 'examplespammer').
      and_return(user)

    expect(@channel).to receive(:notify).with("Report examplespammer as SPAMMER")
    call "#twitter", 'spam', %w(examplespammer)
  end
end
