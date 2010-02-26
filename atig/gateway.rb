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
    include Util

    MAX_MODE_PARAMS = 3
    WSP_REGEX       = Regexp.new("\\r\\n|[\\r\\n\\t#{"\\u00A0\\u1680\\u180E\\u2002-\\u200D\\u202F\\u205F\\u2060\\uFEFF" if "\u0000" == "\000"}]")

    def initialize(*args)
      super

    end

    def on_user(m)
      super

      @real, *opts = (@opts.name || @real).split(" ")
      @opts = parse_opts opts

      @twitter = Twitter.new @log, @real, @pass, @opts.httpproxy

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
        post @prefix, TOPIC, main_channel, generate_status_message(@me.status.text)
      end

      log :info,"Client options: #{@opts.marshal_dump.inspect}"

      @opts.tid = begin
                    c = @opts.tid # expect: 0..15, true, "0,1"
                    b = nil
                    c, b = c.split(",", 2).map {|i| i.to_i } if c.respond_to? :split
                    c = 10 unless (0 .. 15).include? c # 10: teal
                    if (0 .. 15).include?(b)
                      "\003%.2d,%.2d[%%s]\017" % [c, b]
                    else
                      "\003%.2d[%%s]\017"      % c
                    end
                  end if @opts.tid


      @api = Scheduler.new @log, @twitter
      @db = Database.new @log,100
      Agent::Timeline.new(@log, @api, @db)
      @db.status.listen do|_, s|
        message(s, main_channel)
      end
    end

    private
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

    def generate_status_message(mesg)
      mesg = decode_utf7(mesg)
      mesg.delete!("\000\001")
      mesg.gsub!("&gt;", ">")
      mesg.gsub!("&lt;", "<")
      mesg.gsub!(WSP_REGEX, " ")
      mesg = untinyurl(mesg)
      mesg.sub!(@rsuffix_regex, "") if @rsuffix_regex
      mesg.strip
    end

    def decode_utf7(str)
      return str unless defined? ::Iconv and str.include?("+")

      str.sub!(/\A(?:.+ > |.+\z)/) { Iconv.iconv("UTF-8", "UTF-7", $&).join }
      #FIXME str = "[utf7]: #{str}" if str =~ /[^a-z0-9\s]/i
      str
    rescue Iconv::IllegalSequence
      str
    rescue => e
      @log.error e
      str
    end

    def untinyurl(text)
      text.gsub(@opts.untiny_whole_urls ? URI.regexp(%w[http https]) : %r{
			http:// (?:
				(?: bit\.ly | (?: tin | rub) yurl\.com | j\.mp
				  | is\.gd | cli\.gs | tr\.im | u\.nu | airme\.us
				  | ff\.im | twurl.nl | bkite\.com | tumblr\.com
				  | pic\.gd | sn\.im | digg\.com )
				/ [0-9a-z=-]+ |
				blip\.fm/~ (?> [0-9a-z]+) (?! /) |
				flic\.kr/[a-z0-9/]+
			)
		}ix) {|url| "#{resolve_http_redirect(URI(url)) || url}" }
    end

    def message(struct, target, tid = nil, str = nil, command = PRIVMSG)
      unless str
        status = struct.status || struct
        str = status.text
        str  = "\00310♺ \017" + str if status.retweeted_status
        if command != PRIVMSG
          time = Time.parse(status.created_at) rescue Time.now
          str  = "#{time.strftime(@opts.strftime || "%m-%d %H:%M")} #{str}" # TODO: color
        end
      end
      user        = struct.user || struct
      screen_name = user.screen_name

      prefix = prefix(user)
      str    = generate_status_message(str)
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
