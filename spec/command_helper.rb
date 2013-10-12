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

  def limit; @api.limit end
  def remain; @api.remain end
  def reset; @api.reset end
end

class FakeDb
  attr_reader :statuses, :followings,:lists, :me
  def initialize(statuses, followings,lists, me)
    @statuses = statuses
    @followings = followings
    @lists = lists
    @me = me
  end

  def transaction(&f)
    f.call self
  end
end

class FakeDbEntry
  def initialize(name)
    @name = name
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
    @statuses   = FakeDbEntry.new 'status DB'
    @followings = FakeDbEntry.new 'followings DB'
    @lists      = {
      "A" =>  FakeDbEntry.new('list A'),
      "B" =>  FakeDbEntry.new('list B')
    }

    @me         = user 1,'me'
    @db         = FakeDb.new @statuses, @followings, @lists, @me
    @command = klass.new context, @gateway, FakeScheduler.new(@api), @db
  end

  def call(channel, command, args)
    @gateway.action.call channel, "#{command} #{args.join(' ')}", command, args
  end

  def stub_status(key, hash)
    @statuses.stub(key).and_return{|arg,*_|
      hash.fetch(arg, hash[:default])
    }
  end
end
