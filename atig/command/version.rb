# -*- mode:ruby; coding:utf-8 -*-

require 'atig/twitter'
require 'atig/command/command'

module Atig
  module Command
    class Version  < Atig::Command::Command
      def command_name; %w(version) end

      def action(target, mesg, command,args)
        if args.empty?
          yield "/me #{command} <ID>"
          return
        end
        nick,*_ = args

        entries = db.statuses.find_by_screen_name(nick, :limit => 1)
        if entries && !entries.empty? then
          entry = TwitterStruct.make('user'   => entries.first.user,
                                     'status' => { 'text' =>
                                       format(entries.first.status.source) })
          gateway[target].message entry, Net::IRC::Constants::NOTICE
        else
          api.delay(0) do|t|
            begin
              user = t.get("users/show", { :screen_name => nick})
              db.statuses.transaction do|d|
                d.add :user => user, :status => user.status, :source => :version
                entry = TwitterStruct.make('user'   => user,
                                           'status' => { 'text' =>
                                             format(user.status.source) })
                gateway[target].message entry, Net::IRC::Constants::NOTICE
              end
            rescue Twitter::APIFailed => e
              yield e.to_s
            end
          end
        end
      end

      def format(source)
        version = source.gsub(/<[^>]*>/, "").strip
        version << " <#{$1}>" if source =~ / href="([^"]+)/
        Net::IRC.ctcp_encode version
      end
    end
  end
end
