# -*- mode:ruby; coding:utf-8 -*-

require 'atig/command/option'

describe Atig::Command::Option do
  include CommandHelper

  before do
    @command = init Atig::Command::Option
  end

  it "should provide option command" do
    expect(@command.command_name).to eq(%w(opt opts option options))
  end
end

describe Atig::Command::Option, 'when have many property' do
  include CommandHelper

  before do
    @command = init Atig::Command::Option
    @opts.foo1 = true
    @opts.foo2 = 42
    @opts.foo3 = 42.1

    allow(@opts).to receive(:foo1=)
    allow(@opts).to receive(:foo2=)
    allow(@opts).to receive(:foo3=)
  end

  it "should list up values" do
    xs = []
    allow(@channel).to receive(:notify){|x| xs << x}
    call '#twitter', 'opt', %w()
    expect(xs).to eq([
                  "foo1 => true",
                  "foo2 => 42",
                  "foo3 => 42.1",
                 ])
  end
end


describe Atig::Command::Option, 'when have bool property' do
  include CommandHelper

  before do
    @command = init Atig::Command::Option
    allow(@opts).to receive(:foo).and_return true
    allow(@opts).to receive(:foo=){|v| @value = v }
    allow(@channel).to receive(:notify)
  end

  it "should show the value" do
    expect(@channel).to receive(:notify).with("foo => true")
    call '#twitter', 'opt', %w(foo)
  end

  it "should update the value" do
    call '#twitter', 'opt', %w(foo false)
    expect(@value).to be_falsey
  end
end

describe Atig::Command::Option, 'when have int property' do
  include CommandHelper

  before do
    @command = init Atig::Command::Option
    allow(@opts).to receive(:foo).and_return 42
    allow(@opts).to receive(:foo=){|v| @value = v }
    allow(@channel).to receive(:notify)
  end

  it "should show the value" do
    expect(@channel).to receive(:notify).with("foo => 42")
    call '#twitter', 'opt', %w(foo)
  end

  it "should update the value" do
    call '#twitter', 'opt', %w(foo 42)
    expect(@value).to eq(42)
  end
end

describe Atig::Command::Option, 'when have float property' do
  include CommandHelper

  before do
    @command = init Atig::Command::Option
    allow(@opts).to receive(:foo).and_return 1.23
    allow(@opts).to receive(:foo=){|v| @value = v }
    allow(@channel).to receive(:notify)
  end

  it "should show the value" do
    expect(@channel).to receive(:notify).with("foo => 1.23")
    call '#twitter', 'opt', %w(foo)
  end

  it "should update the value" do
    call '#twitter', 'opt', %w(foo 1.24)
    expect(@value).to eq(1.24)
  end
end

describe Atig::Command::Option, 'when have string property' do
  include CommandHelper

  before do
    @command = init Atig::Command::Option
    allow(@opts).to receive(:foo).and_return "bar"
    allow(@opts).to receive(:foo=){|v| @value = v }
    allow(@channel).to receive(:notify)
  end

  it "should show the value" do
    expect(@channel).to receive(:notify).with("foo => bar")
    call '#twitter', 'opt', %w(foo)
  end

  it "should update the value" do
    call '#twitter', 'opt', %w(foo baz)
    expect(@value).to eq('baz')
  end

  it "should update the value" do
    call '#twitter', 'opt', %w(foo blah Blah)
    expect(@value).to eq('blah Blah')
  end
end
