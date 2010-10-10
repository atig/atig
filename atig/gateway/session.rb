#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'fileutils'
require 'atig/util'
require "net/irc"
require "ostruct"
require "time"
require 'yaml'
require 'atig/url_escape'
require 'atig/twitter'
require 'atig/search_twitter'
require 'atig/stream'
require 'atig/oauth'
require 'atig/db/db'
require 'atig/gateway/channel'
require 'atig/option'

begin
  require 'continuation'
rescue LoadError => e
end

module Atig
  module Gateway
    class Session < Net::IRC::Server::Session
      include Util

      class << self
        def self.class_writer(*ids)
          ids.each do|id|
            module_eval <<END
def #{id}=(arg)
  @@#{id} = arg
end
END
          end
        end

        class_writer :commands, :agents, :ifilters, :ofilters, :channels
      end

      def initialize(*args)
        super
        @on_message = nil
      end

      def post(*args)
        super
      end

      def update_status(ret, target, msg='')
        @db.transaction do|db|
          db.statuses.add(:source => :me, :status => ret, :user => ret.user )
        end

        msg = "(#{msg})" unless msg.empty?
        self[target].notify "Status updated #{msg}"
      end

      def channel(name,opts={})
        opts.update(:session => self,
                    :name    => name,
                    :filters => @ifilters,
                    :prefix  => @prefix,
                    :nick    => @nick,
                    :opts    => @opts)
        channel = Channel.new opts
        @channels[name] = channel
        channel
      end

      def [](name)
        @channels[name]
      end

      def output_message(query)
        @ofilters.inject(query) {|x, f| f.call x }
      end

      def ctcp_action(*commands, &block)
        commands.each do |command|
          @ctcp_actions[command] = block
        end
      end

      def prefix(u)
        nick = u.screen_name
        nick = "@#{nick}" if @opts.athack
        user = "id=%.9d" % u.id
        host = "twitter"
        host += "/protected" if u.protected

        Net::IRC::Prefix.new("#{nick}!#{user}@#{host}")
      end

      def topic(entry)
        @channels.each{|_, ch| ch.topic entry }
      end

      protected
      def on_message(m)
        GC.start
        @on_message.call(m) if @on_message
      end

      def on_user(m)
        super
        @thread_group = ThreadGroup.new
        @thread_group.add Thread.current
        @ctcp_actions = {}
        @channels     = {}
        load_config

        @opts = Atig::Option.parse @real
        context = OpenStruct.new(:log=>@log, :opts=>@opts)

        oauth = OAuth.new(context, @nick)
        unless oauth.verified? then
          channel = channel '#oauth'
          channel.join_me
          channel.notify "Please approve me at #{oauth.url}"
          callcc{|cc|
            @on_message = lambda{|x|
              if x.command.downcase == 'privmsg' then
                _, mesg = *x.params
                if oauth.verify(mesg.strip)
                  channel.part_me "Verified"
                  save_config
                  @on_message = nil
                  cc.call
                end
              end
              return true
            }
            return
          }
        end

        log :debug, "initialize Twitter"
        twitter = Twitter.new   context, oauth.access
        search  = SearchTwitter.new context
        stream  = Stream.new context, oauth.stream_access if @opts.stream
        @api    = Scheduler.new context, twitter, search, stream

        log :debug, "initialize filter"
        @ifilters = run_new @@ifilters, context
        @ofilters = run_new @@ofilters, context

        @api.delay(0) do|t|
          me  = t.post "account/update_profile"
          unless me then
            log :info, <<END
Failed to access API.
Please check Twitter Status <http://status.twitter.com/> and try again later.
END
            finish
          end
          @prefix = prefix me
          @user   = @prefix.user
          @host   = @prefix.host

          post server_name, MODE, @nick, "+o"

          @db = Atig::Db::Db.new context, :me=>me, :size=> 100
          run_new @@commands, context, self, @api, @db
          run_new @@agents  , context, @api, @db
          run_new @@channels, context, self, @db

          @db.statuses.add :user => me, :source => :me, :status => me.status
        end
      end

      def run_new(klasses,*args)
        (klasses || []).map do|klass|
          if klass.respond_to?(:new)
            klass.new(*args)
          else
            klass
          end
        end
      end

      def on_disconnected
        (@thread_group.list - [Thread.current]).each {|t| t.kill }
      end

      CONFIG_FILE = File.expand_path("~/.atig/oauth")
      def save_config
        FileUtils.mkdir_p File.dirname(CONFIG_FILE)
        File.open(CONFIG_FILE, "w") {|io|
          YAML.dump(OAuth.dump,io)
        }
        FileUtils.chmod 0600, CONFIG_FILE
      end

      def load_config
        FileUtils.mkdir_p File.dirname(CONFIG_FILE)
        OAuth.load(YAML.load_file(CONFIG_FILE)) rescue nil
      end

      def on_privmsg(m)
        target, mesg = *m.params
        m.ctcps.each {|ctcp| on_ctcp(target, ctcp) } if m.ctcp?

        case
        when mesg.empty?
          return
        when mesg.sub!(/\A +/, "")
          on_ctcp_action(target, mesg)
        when target[0] != ?#
          channel target
          on_ctcp_action(target, "dm #{target} #{mesg}")
        when (@opts.old_style_reply and mesg =~ /\A@(?>([A-Za-z0-9_]{1,15}))[^A-Za-z0-9_]/)
          on_ctcp_action(target, "reply #{$1} #{mesg}")
        else
          on_ctcp_action(target, "status #{mesg}")
        end
      end

      def on_ctcp(target, mesg)
        type, mesg = mesg.split(" ", 2)
        method = "on_ctcp_#{type.downcase}".to_sym
        send(method, target, mesg) if respond_to? method, true
      end

      def on_ctcp_action(target, mesg)
        command, *args = mesg.split(" ")
        last_match = nil
        commond = command.to_s.downcase
        _, action = @ctcp_actions.find{|define, f|
          r = (define === command)
          last_match = Regexp.last_match
          r
        }
        if action then
          safe {
            action.call(target, mesg, last_match || command, args)
          }
        else
          self[target].notify "[atig.rb] CTCP ACTION COMMANDS:"
          @ctcp_actions.keys.each do |c|
            self[target].notify c.to_s
          end
        end
      end

      def on_invite(m)
        nick, channel = *m.params
        if not nick.screen_name? or @db.me.screen_name.casecmp(nick).zero?
          post server_name, ERR_NOSUCHNICK, nick, "No such nick: #{nick}" # or yourself
          return
        end

        unless @channels.key? channel
          post server_name, ERR_NOSUCHNICK, nick, "No such channel: #{channel}"
          return
        end

        @api.delay(0){|api| @channels[channel].on_invite(api, nick) }
      end

      def on_kick(m)
        channel, nick, msg = *m.params

        if not nick.screen_name? or @db.me.screen_name.casecmp(nick).zero?
          post server_name, ERR_NOSUCHNICK, nick, "No such nick: #{nick}" # or yourself
          return
        end

        unless @channels.key? channel
          post server_name, ERR_NOSUCHNICK, nick, "No such channel: #{channel}"
          return
        end

        @api.delay(0){|api| @channels[channel].on_kick(api, nick) }
      end

      def on_whois(m)
        nick = m.params[0]
        unless nick.screen_name?
          post server_name, ERR_NOSUCHNICK, nick, "No such nick/channel"
          return
        end
        on_ctcp_action(nil, "whois #{nick}")
      end

      def on_topic(m)
        channel,topic = *m.params
        on_ctcp_action(channel, "topic #{topic}")
      end

      def on_who(m)
        channel  = m.params[0]

        unless @channels.key? channel
          post server_name, ERR_NOSUCHNICK, nick, "No such channel: #{channel}"
          return
        end
        @channels[channel].on_who do|user|
          p user
          #     "<channel> <user> <host> <server> <nick>
          #         ( "H" / "G" > ["*"] [ ( "@" / "+" ) ]
          #             :<hopcount> <real name>"
          prefix = prefix(user)
          server = 'twitter.com'
          mode   = case prefix.nick
                   when @nick                     then "~"
                   else                                "+"
                   end
          real = user.name
          post server_name, RPL_WHOREPLY, @nick, channel, prefix.user, prefix.host, server, prefix.nick, "H*#{mode}", "1 #{real}"
        end
        post server_name, RPL_ENDOFWHO, @nick, channel
      end

      def available_user_modes
        "o"
      end

      def available_channel_modes
        "mntiovah"
      end
    end
  end
end
