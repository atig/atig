#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'
require "net/irc"
require "ostruct"
require "time"
require 'atig/url_escape'
require 'atig/fake_twitter'
require 'atig/twitter'
require 'atig/db/db'

module Net::IRC::Constants
  RPL_WHOISBOT = "335"
  RPL_CREATEONTIME = "329"
end

module Atig
  class Gateway < Net::IRC::Server::Session
    @@commands =
      @@agents =
      @@ifilters =
      @@ofilters = []

    class << self
      def commands=(cmds)
        @@commands = cmds
      end

      def agents=(agents)
        @@agents = agents
      end

      def ifilters=(ifilters)
        @@ifilters = ifilters
      end

      def ofilters=(ofilters)
        @@ofilters = ofilters
      end
    end

    include Util

    MAX_MODE_PARAMS = 3

    attr_reader :api, :db, :opts, :ifilters, :ofilters

    def initialize(*args); super end

    def ctcp_action(*commands, &block)
      commands.each do |command|
        @ctcp_actions[command] = block
      end
    end

    def message(entry, target,  command = PRIVMSG)
      user        = entry.user
      screen_name = user.screen_name
      prefix      = prefix user
      str         = input_message(entry)

      post prefix, command, target, str
    end

    def api_source
      "#{@opts.api_source || "tigrb"}"
    end

    alias_method :__log__, :log
    def log(kind, str)
      if kind == :info or kind == :error
        notify main_channel, str
      end
      __log__(kind, str)
    end

    def notify(target, str)
      post server_name, NOTICE, target, str.gsub(/\r\n|[\r\n]/, " ")
    end

    def oops(status)
      "Oops! Your update was over 140 characters. We sent the short version" <<
        " to your friends (they can view the entire update on the Web <" <<
        permalink(status) << ">)."
    end

    def permalink(struct)
      "http://twitter.com/#{struct.user.screen_name}/statuses/#{struct.id}"
    end

    def input_message(entry)
      status = entry.status.merge(:tid=>entry.tid)
      @ifilters.inject(status) {|x, f| f.call x }.text
    end

    def output_message(query)
      @ofilters.inject(query) {|x, f| f.call x }
    end

    def update_my_status(ret, target, msg='')
      notify target, oops(ret) if ret.truncated
      @db.transaction do|db|
        db.statuses.add(:source => :me, :status => ret, :user => ret.user )
      end

      msg = "(#{msg})" unless msg.empty?
      notify target, "Status updated #{msg}"
    end

    protected
    def on_user(m)
      super

      log :debug, "client option"
      @real, *opts = (@opts.name || @real).split(" ")
      @opts = parse_opts opts
      log :info,"Client options: #{@opts.marshal_dump.inspect}"

      log :debug, "initialize Twitter"
      @twitter = Twitter.new @log, @real, @pass
      @api     = Scheduler.new @log, @twitter

      log :debug, "initialize filter"
      @ifilters = @@ifilters.map do|ifilter|
        if ifilter.respond_to? :new
          ifilter.new(@log, @opts)
        else
          ifilter
        end
      end

      @ofilters = @@ofilters.map do|ofilter|
        if ofilter.respond_to? :new
          ofilter.new(@log, @opts)
        else
          ofilter
        end
      end

      log :debug, "initialize Database"
      me  = update_profile
      return unless me

      @prefix = prefix(me)
      @user   = @prefix.user
      @host   = @prefix.host
      post server_name, MODE, @nick, "+o"
      create_channel main_channel
      create_channel mention_channel

      @db = Atig::Db::Db.new @log, :me=>me, :size=> 1000

      # main channel
      @db.statuses.listen do|entry|
        case entry.source
        when :timeline, :me
          message(entry, main_channel)
        end
      end

      # lists
      @db.statuses.listen do|entry|
        case entry.source
        when :timeline, :me
          lists = @db.lists.find_by_screen_name(entry.user.screen_name)
          lists.each do|name|
            message(entry, "##{name}")
          end
        when :list
          message(entry,"##{entry.list}")
        end
      end

      # main topic
      @db.statuses.listen do|entry|
        case entry.source
        when :me
          mesg = input_message(entry)
          post @prefix, TOPIC, main_channel, mesg
        when :timeline
          if entry.user.id == @db.me.id then
            mesg = input_message(entry)
            post @prefix, TOPIC, main_channel, mesg
          end
        end
      end

      # mention
      @db.statuses.listen do|entry|
        case entry.source
        when :timeline,:me
          name = @db.me.screen_name
          message(entry, mention_channel) if entry.status.text.include?(name)
         when :mention
          message(entry, mention_channel)
        end
      end

      # followings
      @db.followings.listen do|kind, users|
        case kind
        when :join
          join main_channel, users
        when :bye
          users.each {|u|
            post prefix(u), PART, main_channel, ""
          }
        when :mode
        end
        log :debug, "set modes for #{db.followings.size} friend"
      end

      # list followings
      @db.lists.listen do|kind, name, users|
        channel = "##{name}"
        case kind
        when :new
          create_channel channel
        when :del
          post @prefix, PART, channel, "No longer follow the list #{name}"
        when :join
          join channel, users
        when :bye
          users.each {|u|
            post prefix(u), PART, main_channel, ""
          }
        when :mode
        end
      end

      # dm
      @db.dms.listen do|dm|
        message(dm, @nick)
      end

      log :debug, "initialize actions"
      @ctcp_actions = {}
      @@commands.each do|c|
        log :debug,"command #{c.inspect}"
        c.new self
      end

      log :debug, "initialize agent"
      @@agents.each do|agent|
        agent.new(@log, @api, @db)
      end

      log :debug, "server response"


      @db.statuses.add :user => me, :source => :me, :status => me.status
    end

    def on_privmsg(m)
      target, mesg = *m.params

      m.ctcps.each {|ctcp| on_ctcp(target, ctcp) } if m.ctcp?

      return if mesg.empty?
      return on_ctcp_action(target, mesg) if mesg.sub!(/\A +/, "")

      previous = @db.me.status
      if previous and
          ((Time.now - Time.parse(previous.created_at)).to_i < 60*60*24 rescue true) and
          mesg.strip == previous.text.strip
        log :info, "You can't submit the same status twice in a row."
        return
      end

      q = output_message(:status => mesg, :source => api_source)

      @api.delay(0, :retry=>3) do|t|
        ret = t.post("statuses/update", q)
        safe {
          update_my_status ret,target
        }
      end
    end

    def on_ctcp(target, mesg)
      type, mesg = mesg.split(" ", 2)
      method = "on_ctcp_#{type.downcase}".to_sym
      send(method, target, mesg) if respond_to? method, true
    end

    def on_ctcp_action(target, mesg)
      safe do
        command, *args = mesg.split(" ")
        if command
          command.downcase!
          @ctcp_actions.each do |define, f|
            if define === command
                f.call(target, mesg, Regexp.last_match || command, args)
            end
          end
        else
          log :info, "[tig.rb] CTCP ACTION COMMANDS:"
          @ctcp_actions.keys.each do |c|
            log :info, c
          end
        end
      end
    end

    private

    def create_channel(channel)
      post @prefix, JOIN, channel
      post server_name, MODE, channel, "+mto", @nick
      post server_name, MODE, channel, "+q", @nick
    end

    def update_profile
      @api.delay(0, :retry=>3) do|t|
        t.post "account/update_profile"
      end
    rescue Twitter::APIFailed => e
      log :info, <<END
Failed to access API 3 times.
Please check your username/email and password combination,
Twitter Status <http://status.twitter.com/> and try again later.
END
      finish
    end

    def parse_opts(opts)
      opts = opts.inject({}) do |r, i|
        key, value = i.split("=", 2)

        r.update key => case value
                        when nil                      then true
                        when /\A\d+\z/                then value.to_i
                        when /\A(?:\d+\.\d*|\.\d+)\z/ then value.to_f
                        else                               value
                        end
      end
      OpenStruct.new opts
    end

    def join(channel, users)
      params = []
      users.each do |user|
        prefix = prefix(user)
        post prefix, JOIN, channel
        case
        when user.protected
          params << ["v", prefix.nick]
        when user.only
          params << ["o", prefix.nick]
        end
        next if params.size < MAX_MODE_PARAMS

        post server_name, MODE, channel, "+#{params.map {|m,_| m }.join}", *params.map {|_,n| n}
        params = []
      end
      post server_name, MODE, channel, "+#{params.map {|m,_| m }.join}", *params.map {|_,n| n} unless params.empty?
      users
    end


    def set_modes(channel, users)
      params = []
      users.each do |user|
        prefix = prefix(user)
        case
        when user.protected
          params << ["v", prefix.nick]
        when ! @db.followers.include?(user.id)
          params << ["o", prefix.nick]
        end
        next if params.size < MAX_MODE_PARAMS

        post server_name, MODE, channel, "+#{params.map {|m,_| m }.join}", *params.map {|_,n| n}
        params = []
      end
      post server_name, MODE, channel, "+#{params.map {|m,_| m }.join}", *params.map {|_,n| n} unless params.empty?
    end

    def prefix(u)
      nick = u.screen_name
      nick = "@#{nick}" if @opts.athack
      user = "id=%.9d" % u.id
      host = "twitter"
      host += "/protected" if u.protected

      Prefix.new("#{nick}!#{user}@#{host}")
    end

    def available_user_modes
      "o"
    end

    def available_channel_modes
      "mntiovah"
    end

    def main_channel
      @opts.main_channel || "#twitter"
    end

    def mention_channel
      @opts.mention_channel || "#mention"
    end
  end
end
