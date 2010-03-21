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

  def server_name; "server-name" end
end

class FakeScheduler
  def initialize(api)
    @api = api
  end

  def delay(interval,opt={},&f)
    f.call @api
  end

  def limit
    @api.limit
  end
end

class FakeDb
  attr_reader :statuses, :followings, :me
  def initialize(statuses, followings, me)
    @statuses = statuses
    @followings = followings
    @me = me
  end

  def transaction(&f)
    f.call self
  end
end

module CommandHelper
  def init(klass)
    @log    = mock 'log'
    @opts   = Atig::Option.new({})
    context = OpenStruct.new :log=>@log, :opts=>@opts

    @channel    = mock 'channel'
    @gateway    = FakeGateway.new @channel
    @api        = mock 'api'
    @statuses   = mock 'status DB'
    @followings = mock 'following DB'
    @me         = user 1,'me'
    @db         = FakeDb.new @statuses, @followings, @me
    @command = klass.new context, @gateway, FakeScheduler.new(@api), @db
  end

  def call(channel, command, args)
    @gateway.action.call channel, "#{command} #{args.join(' ')}", command, args
  end
end
