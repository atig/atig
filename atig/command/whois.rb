#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-
require 'atig/command/info'
require 'time'
module Atig
  module Command
    class Whois < Atig::Command::Command
      def command_name; %w(whois) end

      def action(target, mesg, command,args)
        if args.empty?
          yield "/me #{command} <ID>"
          return
        end
        nick,*_ = args

        Atig::Command::Info::user(db, api, nick) do|user|
          id = "id=#{user.id}"
          host = "twitter.com"
          host += "/protected" if user.protected
          desc      = user.name
          desc      = "#{desc} / #{user.description}".gsub(/\s+/, " ") if user.description and not user.description.empty?
          signon_at = ::Time.parse(user.created_at).to_i rescue 0
          idle_sec  = (::Time.now - (user.status ? ::Time.parse(user.status.created_at) : signon_at)).to_i rescue 0
          location  = user.location
          location  = "SoMa neighborhood of San Francisco, CA" if location.nil? or location.empty?

          send Net::IRC::Constants::RPL_WHOISUSER,   nick, id, host, "*", desc
          send Net::IRC::Constants::RPL_WHOISSERVER, nick, host, location
          send Net::IRC::Constants::RPL_WHOISIDLE,   nick, "#{idle_sec}", "#{signon_at}", "seconds idle, signon time"
          send Net::IRC::Constants::RPL_ENDOFWHOIS,  nick, "End of WHOIS list"
        end
      end

      def send(command,nick,*params)
        gateway.post gateway.server_name, command, db.me.screen_name, nick, *params
      end
    end
  end
end
