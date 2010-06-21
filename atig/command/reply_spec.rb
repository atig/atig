#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/command/reply'
require 'atig/command/command_helper'

describe Atig::Command::Reply do
  include CommandHelper
  before do
    @command = init Atig::Command::Reply

    target = status 'blah blah', 'id'=>'1'
    entry  = entry user(1,'mzp'), target
    @res   = mock 'res'

    stub_status(:find_by_tid,'a' => entry)
    stub_status(:find_by_sid,'mzp:a' => entry)
    stub_status(:find_by_screen_name,'mzp' => [ entry ], :default => [])
  end

  it "should have '/me status' name" do
    @gateway.names.should == %w(mention re reply rp)
  end

  it "should post the status" do
    @api.should_receive(:post).
      with('statuses/update', {:status=>'abc @mzp', :in_reply_to_status_id=>'1'}).
      and_return(@res)

    call '#twitter', "reply", %w(a abc @mzp)

    @gateway.updated.should  == [ @res, '#twitter', 'In reply to mzp: blah blah' ]
    @gateway.filtered.should == { :status => 'abc @mzp', :in_reply_to_status_id=>'1'}
  end

  it "should post the status by sid" do
    @api.should_receive(:post).
      with('statuses/update', {:status=>'abc @mzp', :in_reply_to_status_id=>'1'}).
      and_return(@res)

    call '#twitter', "reply", %w(mzp:a abc @mzp)

    @gateway.updated.should  == [ @res, '#twitter', 'In reply to mzp: blah blah' ]
    @gateway.filtered.should == { :status => 'abc @mzp', :in_reply_to_status_id=>'1'}
  end

  it "should post the status by API" do
    @api.should_receive(:post).
      with('statuses/update', {:status=>'abc @mzp', :in_reply_to_status_id=>'1'}).
      and_return(@res)

    call '#twitter', "reply", %w(a abc @mzp)

    @gateway.updated.should  == [ @res, '#twitter', 'In reply to mzp: blah blah' ]
    @gateway.filtered.should == { :status => 'abc @mzp', :in_reply_to_status_id=>'1'}
  end

  it "should post the status with screen_name" do
    @api.should_receive(:post).
      with('statuses/update', {:status=>'abc @mzp', :in_reply_to_status_id=>'1'}).
      and_return(@res)

    call '#twitter', "reply", %w(mzp abc @mzp)

    @gateway.updated.should  == [ @res, '#twitter', 'In reply to mzp: blah blah' ]
    @gateway.filtered.should == { :status => 'abc @mzp', :in_reply_to_status_id=>'1'}
  end

  it "should add screen name as prefix" do
    @api.should_receive(:post).
      with('statuses/update', {:status=>'@mzp mzp', :in_reply_to_status_id=>'1'}).
      and_return(@res)

    call '#twitter', "reply", %w(a mzp)

    @gateway.updated.should  == [ @res, '#twitter', 'In reply to mzp: blah blah' ]
    @gateway.filtered.should == { :status => '@mzp mzp', :in_reply_to_status_id=>'1'}
  end
end
