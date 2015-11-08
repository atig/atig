# -*- mode:ruby; coding:utf-8 -*-

require 'atig/db/listenable'

class SampleListener
  include Atig::Db::Listenable

  def hi(*args)
    notify(*args)
  end
end

describe Atig::Db::Listenable, "when it is called" do
  before do
    @listeners = SampleListener.new

    @args = []
    @listeners.listen {|*args|  @args << args }
    @listeners.listen {|*args|  @args << args }
    @listeners.listen {|*args|  @args << args }
  end

  it "should call all listener" do
    @listeners.hi 1,2,3

    expect(@args.length).to eq(3)
    1.upto(2) {|i|
      expect(@args[i]).to eq([1,2,3])
    }
  end
end
