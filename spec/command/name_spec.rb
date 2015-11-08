# -*- mode:ruby; coding:utf-8 -*-

require 'atig/command/name'

describe Atig::Command::Name do
  include CommandHelper

  before do
    @command = init Atig::Command::Name
  end

  it "should update name" do
    expect(@api).to receive(:post).with('account/update_profile',:name=>'mzp')
    expect(@channel).to receive(:notify).with("You are named mzp.")
    call '#twitter', 'name', %w(mzp)
  end
end
