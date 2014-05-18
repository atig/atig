# -*- mode:ruby; coding:utf-8 -*-

require File.expand_path( '../../spec_helper', __FILE__ )
require 'atig/command/destroy'

describe Atig::Command::Destroy,"when status is not removed" do
  include CommandHelper

  before do
    @command = init Atig::Command::Destroy
  end

  it "should specified other's status" do
    entry  = entry user(2,'other'), status('blah blah', 'id'=>'1')
    allow(@statuses).to receive(:find_by_tid).with('b').and_return(entry)

    expect(@channel).to receive(:notify).with("The status you specified by the ID tid is not yours.")
    call "#twitter","destory",%w(b)
  end
end

describe Atig::Command::Destroy,"when remove recently tweet" do
  include CommandHelper

  before do
    @command = init Atig::Command::Destroy

    target = status 'blah blah', 'id'=>'1'
    entry  = entry @me, target,'entry',1
    @res   = double 'res'

    stub_status(:find_by_tid,'a' => entry)
    stub_status(:find_by_sid,'mzp:a' => entry)
    stub_status(:find_by_screen_name,'mzp' => [ entry ], default:[])

    # api
    expect(@api).to receive(:post).with("statuses/destroy/1")

    # notice
    expect(@channel).to receive(:notify).with("Destroyed: blah blah")

    # update topics
    new_entry  = entry @me, status('foo', 'id'=>'2')
    expect(@gateway).to receive(:topic).with(new_entry)

    expect(@statuses).to receive(:remove_by_id).with(1){
      expect(@statuses).to receive(:find_by_screen_name).with(@me.screen_name,:limit=>1){
        [ new_entry ]
      }
    }
  end

  it "should specified by tid" do
    call "#twitter","destory",%w(a)
  end

  it "should remove status by user" do
    call "#twitter","destory",%w(mzp)
  end

  it "should remove status by sid" do
    call "#twitter","destory",%w(mzp:a)
  end
end

describe Atig::Command::Destroy,"when remove old tweet" do
  include CommandHelper

  before do
    @command = init Atig::Command::Destroy

    target = status 'blah blah', 'id'=>'1'
    entry  = entry @me, target,'entry',1
    @res   = double 'res'

    stub_status(:find_by_tid,'a' => entry)
    stub_status(:find_by_sid,'mzp:a' => entry)
    stub_status(:find_by_screen_name, @db.me.screen_name => [ entry ], default:[])

    # api
    expect(@api).to receive(:post).with("statuses/destroy/1")

    # notice
    expect(@channel).to receive(:notify).with("Destroyed: blah blah")

    # update topics
    expect(@statuses).to receive(:remove_by_id).with(1)
  end

  it "should specified by tid" do
    call "#twitter","destory",%w(a)
  end

  it "should remove status by sid" do
    call "#twitter","destory",%w(mzp:a)
  end
end
