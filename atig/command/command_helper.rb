#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

class FakeGateway
  attr_reader :names,:action,:filtered,:updated, :notified

  def initialize(channel)
    @channel = channel
  end

  def ctcp_action(*names, &action)
    @names  = names
    @action = action
  end

  def output_message(m); @filtered = m end

  def update_status(*args); @updated = args end

  def [](name)
    @notified = name
    @channel
  end
end

class FakeScheduler
  def initialize(api)
    @api = api
  end

  def delay(*args,&f)
    f.call @api
  end
end

def user(id, name)
  user = stub("User-#{name}")
  user.stub!(:id).and_return(id)
  user.stub!(:screen_name).and_return(name)
  user
end

def status(text)
  status = stub("Status-#{text}")
  status.stub!(:text).and_return(text)
  status
end

def entry(user,status)
  entry = stub 'entry'
  entry.stub!('user').and_return(user)
  entry.stub!('status').and_return(status)
  entry
end
