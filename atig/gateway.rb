#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/util'
require "net/irc"
require "ostruct"

module Net::IRC::Constants
  RPL_WHOISBOT = "335"
  RPL_CREATEONTIME = "329"
end

module Atig
  class Gateway < Net::IRC::Server::Session

    def self.agents=(agents)
      @@agents = agents
    end

    def self.ifilters=(ifilters)
      @@ifilters = ifilters
    end

    include Util

    MAX_MODE_PARAMS = 3

    def initialize(*args)
      super

    end

    def on_user(m)
      super

      @real, *opts = (@opts.name || @real).split(" ")
      @opts = parse_opts opts

      @twitter = Twitter.new @log, @real, @pass
      @api     = Scheduler.new @log, @twitter
      @db      = Database.new @log,100
      @db.status.listen do|_, s|
        message(s, main_channel)
      end

      @ifilters = @@ifilters.map do|ifilter|
        if ifilter.respond_to? :new
          ifilter.new(@log, :db => @db, :opts => @opts)
        else
          ifilter
        end
      end

      check_login

      @@agents.each do|agent|
        agent.new(@log, @api, @db)
      end
    end

    private
    def check_login
      retry_count = 0
      begin
        @me = @twitter.post "account/update_profile"
      rescue Twitter::APIFailed => e
        log :error,e.inspect
        sleep 1
        retry_count += 1
        retry if retry_count < 3
        log :info, <<END
Failed to access API 3 times.
Please check your username/email and password combination,
Twitter Status <http://status.twitter.com/> and try again later.
END
        finish
      end

      @prefix = prefix(@me)
      @user   = @prefix.user
      @host   = @prefix.host

      post server_name, MODE, @nick, "+o"
      post @prefix, JOIN, main_channel
      post server_name, MODE, main_channel, "+mto", @nick
      post server_name, MODE, main_channel, "+q", @nick
      if @me.status
        post @prefix, TOPIC, main_channel, generate_status_message(@me.status.text,
                                                                   @me.status)
      end

      log :info,"Client options: #{@opts.marshal_dump.inspect}"
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

    def generate_status_message(mesg, status)
       @ifilters.inject(mesg) {|s, f| f.call(s, status) }
    end

    def message(struct, target, tid = nil, str = nil, command = PRIVMSG)
      unless str
        status = struct.status || struct
        str = status.text
        if command != PRIVMSG
          time = Time.parse(status.created_at) rescue Time.now
          str  = "#{time.strftime(@opts.strftime || "%m-%d %H:%M")} #{str}" # TODO: color
        end
      end
      user        = struct.user || struct
      screen_name = user.screen_name

      prefix = prefix(user)
      str    = generate_status_message(str, status)
      str    = "#{str} #{@opts.tid % tid}" if tid

      post prefix, command, target, str
    end


    alias_method :__log__, :log
    def log(kind, str)
      if kind == :info
        post server_name, NOTICE, main_channel, str.gsub(/\r\n|[\r\n]/, " ")
      end
      __log__(kind, str)
    end

  end
end
