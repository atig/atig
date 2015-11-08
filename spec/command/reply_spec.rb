# -*- mode:ruby; coding:utf-8 -*-

require 'atig/command/reply'

describe Atig::Command::Reply do
  include CommandHelper
  before do
    @command = init Atig::Command::Reply

    target = status 'blah blah', 'id'=>'1'
    entry  = entry user(1,'mzp'), target
    @res   = double 'res'

    stub_status(:find_by_tid,'a' => entry)
    stub_status(:find_by_sid,'mzp:a' => entry)
    stub_status(:find_by_screen_name,'mzp' => [ entry ], default: [])
  end

  it "should have '/me status' name" do
    expect(@gateway.names).to eq(%w(mention re reply rp))
  end

  it "should post the status" do
    expect(@api).to receive(:post).
      with('statuses/update', {status:'abc @mzp', in_reply_to_status_id:'1'}).
      and_return(@res)

    call '#twitter', "reply", %w(a abc @mzp)

    expect(@gateway.updated).to  eq([ @res, '#twitter', 'In reply to mzp: blah blah' ])
    expect(@gateway.filtered).to eq({ status: 'abc @mzp', in_reply_to_status_id:'1'})
  end

  it "should post the status by sid" do
    expect(@api).to receive(:post).
      with('statuses/update', {status:'abc @mzp', in_reply_to_status_id:'1'}).
      and_return(@res)

    call '#twitter', "reply", %w(mzp:a abc @mzp)

    expect(@gateway.updated).to  eq([ @res, '#twitter', 'In reply to mzp: blah blah' ])
    expect(@gateway.filtered).to eq({ status: 'abc @mzp', in_reply_to_status_id:'1'})
  end

  it "should post the status by API" do
    expect(@api).to receive(:post).
      with('statuses/update', {status:'abc @mzp', in_reply_to_status_id:'1'}).
      and_return(@res)

    call '#twitter', "reply", %w(a abc @mzp)

    expect(@gateway.updated).to  eq([ @res, '#twitter', 'In reply to mzp: blah blah' ])
    expect(@gateway.filtered).to eq({ status: 'abc @mzp', in_reply_to_status_id:'1'})
  end

  it "should post the status with screen_name" do
    expect(@api).to receive(:post).
      with('statuses/update', {status:'abc @mzp', in_reply_to_status_id:'1'}).
      and_return(@res)

    call '#twitter', "reply", %w(mzp abc @mzp)

    expect(@gateway.updated).to  eq([ @res, '#twitter', 'In reply to mzp: blah blah' ])
    expect(@gateway.filtered).to eq({ status: 'abc @mzp', in_reply_to_status_id:'1'})
  end

  it "should add screen name as prefix" do
    expect(@api).to receive(:post).
      with('statuses/update', {status:'@mzp mzp', in_reply_to_status_id:'1'}).
      and_return(@res)

    call '#twitter', "reply", %w(a mzp)

    expect(@gateway.updated).to  eq([ @res, '#twitter', 'In reply to mzp: blah blah' ])
    expect(@gateway.filtered).to eq({ status: '@mzp mzp', in_reply_to_status_id:'1'})
  end
end
