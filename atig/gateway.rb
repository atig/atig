#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'fileutils'
require 'atig/util'
require "net/irc"
require "ostruct"
require "time"
require 'yaml'
require 'atig/url_escape'
require 'atig/fake_twitter'
require 'atig/twitter'
require 'atig/oauth'
require 'atig/db/db'
require 'atig/channel_gateway'

begin
  require 'continuation'
rescue LoadError => e
end

module Net::IRC::Constants
  RPL_WHOISBOT = "335"
  RPL_CREATEONTIME = "329"
end

module Atig
  class Gateway < Net::IRC::Server::Session
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
    attr_reader :api, :db, :opts, :ifilters, :ofilters

    def initialize(*args); super end

    def ctcp_action(*commands, &block)
      commands.each do |command|
        @ctcp_actions[command] = block
      end
    end

    def oops(status)
      "Oops! Your update was over 140 characters. We sent the short version" <<
        " to your friends (they can view the entire update on the Web <" <<
        permalink(status) << ">)."
    end

    def permalink(struct)
      "http://twitter.com/#{struct.user.screen_name}/statuses/#{struct.id}"
    end

    def output_message(query)
      @ofilters.inject(query) {|x, f| f.call x }
    end

    def post(*args)
      super
    end

    def update_my_status(ret, target, msg='')
      notify target, oops(ret) if ret.truncated
      @db.transaction do|db|
        db.statuses.add(:source => :me, :status => ret, :user => ret.user )
      end

      msg = "(#{msg})" unless msg.empty?
      notify target, "Status updated #{msg}"
    end

    def channel(name)
      ChannelGateway.new(:session => self,
                         :name    => name,
                         :filters => @ifilters,
                         :me      => @db.me,
                         :opts    => @opts)
    end

    protected
    def on_message(m)
      @on_message.call(m) if @on_message
    end

    def on_user(m)
      super

      log :debug, "client option"
      @real, *opts = (@opts.name || @real).split(" ")
      @opts = parse_opts opts
      log :info,"Client options: #{@opts.marshal_dump.inspect}"
      load_config

      oauth = OAuth.new(@real)
      unless oauth.verified? then
        notify main_channel, "Access this URL and approve => #{oauth.url}"
        notify main_channel, "Please input OAuth Verifier"
        callcc{|cc|
          @on_message = lambda{|m|
            if m.command.downcase == 'privmsg' then
              _, mesg = *m.params
              if oauth.verify(mesg.strip)
                save_config
                cc.call
              end
            end
            return true
          }
          return
        }
      end

      log :debug, "initialize Twitter"
      @twitter = Twitter.new @log, oauth.access
      @api     = Scheduler.new @log, @twitter

      log :debug, "initialize filter"
      @ifilters = (@@ifilters || []).map do|ifilter|
        if ifilter.respond_to? :new
          ifilter.new(@log, @opts)
        else
          ifilter
        end
      end

      @ofilters = (@@ofilters || []).map do|ofilter|
        if ofilter.respond_to? :new
          ofilter.new(@log, @opts)
        else
          ofilter
        end
      end

      log :debug, "initialize Database"
      @api.delay(0) do|t|
        me  = update_profile t
        return unless me

        post server_name, MODE, @nick, "+o"
        @db = Atig::Db::Db.new @log, :me=>me, :size=> 100

        log :debug, "initialize actions"
        @ctcp_actions = {}
        each_new @@commands, self

        log :debug, "initialize agents"
        each_new @@agents, @log, @api, @db

        log :debug, "initialize channels"
        each_new @@channels, self, @db

        @db.statuses.add :user => me, :source => :me, :status => me.status

        # create_channel main_channel
        # create_channel mention_channel

        # # main channel
        # @db.statuses.listen do|entry|
        #   case entry.source
        #   when :timeline, :me
        #     message(entry, main_channel)
        #   end
        # end

        # # lists
        # @db.statuses.listen do|entry|
        #   case entry.source
        #   when :timeline, :me
        #     lists = @db.lists.find_by_screen_name(entry.user.screen_name)
        #     lists.each do|name|
        #       message(entry, "##{name}")
        #     end
        #   when :list
        #     message(entry,"##{entry.list}")
        #   end
        # end

        # # main topic
        # @db.statuses.listen do|entry|
        #   case entry.source
        #   when :me
        #     mesg = input_message(entry)
        #     post @prefix, TOPIC, main_channel, mesg
        #   when :timeline
        #     if entry.user.id == @db.me.id then
        #       mesg = input_message(entry)
        #       post @prefix, TOPIC, main_channel, mesg
        #     end
        #   end
        # end

        # # mention
        # @db.statuses.listen do|entry|
        #   case entry.source
        #   when :timeline,:me
        #     name = @db.me.screen_name
        #     message(entry, mention_channel) if entry.status.text.include?(name)
        #   when :mention
        #     message(entry, mention_channel)
        #   end
        # end

        # # followings
        # @db.followings.listen do|kind, users|
        #   case kind
        #   when :join
        #     join main_channel, users
        #   when :bye
        #     users.each {|u|
        #       post prefix(u), PART, main_channel, ""
        #     }
        #   when :mode
        #   end
        #   log :debug, "set modes for #{db.followings.size} friend"
        # end

        # # list followings
        # @db.lists.listen do|kind, name, users|
        #   channel = "##{name}"
        #   case kind
        #   when :new
        #     create_channel channel
        #   when :del
        #     post @prefix, PART, channel, "No longer follow the list #{name}"
        #   when :join
        #     join channel, users
        #   when :bye
        #     users.each {|u|
        #       post prefix(u), PART, main_channel, ""
        #     }
        #   when :mode
        #   end
        # end

        # # dm
        # @db.dms.listen do|dm|
        #   message(dm, @nick)
        # end
      end
    end

    def each_new(klasses,*args)
      (klasses || []).each do|klass|
        klass.new(*args)
      end
    end

    def save_config
      FileUtils.mkdir_p File.expand_path("~/.atig/")
      File.open(File.expand_path("~/.atig/oauth"),"w") {|io|
        YAML.dump(OAuth.dump,io)
      }
    end

    def load_config
      FileUtils.mkdir_p File.expand_path("~/.atig/")
      OAuth.load(YAML.load_file(File.expand_path("~/.atig/oauth"))) rescue nil
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

      q = output_message(:status => mesg)

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
    def update_profile(t)
      # fixme: retry 3 times
      t.post "account/update_profile"
    rescue Twitter::APIFailed => e
      log :info, <<END
Failed to access API.
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

    def available_user_modes
      "o"
    end

    def available_channel_modes
      "mntiovah"
    end
  end
end
