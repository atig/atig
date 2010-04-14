#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

require 'atig/command/command'
require 'atig/http'

module Atig
  module Command
    class Latest < Atig::Command::Command
      def initialize(*args)
        super

        @http  = Atig::Http.new @log
      end

      def command_name; "latest check_update" end

      def commits
        uri = URI("http://github.com/api/v1/json/mzp/atig/commits/master")
        @log.debug uri.inspect
        res = @http.http(uri).request(@http.req(:get, uri))
        JSON.parse(res.body)['commits']
      end

      def server_version
        @server_version ||= instance_eval {
          head = `git rev-parse HEAD 2>/dev/null`.chomp
          head.empty?? "unknown" : head
        }
      end

      def local_repos?(rev)
        system("git rev-parse --verify #{rev} > /dev/null 2>&1")
      end

      def action(target, mesg, command, args)
        latest  = commits.first['id'][/^[0-9a-z]{40}$/]
        raise "github API changed?" unless latest

        unless local_repos?(latest)
          current  = commits.map {|i| i['id'] }.index(server_version)
          messages = commits[0...current].map {|i| i['message'] }

          yield "\002New version is available.\017 run 'git pull'."
          messages[0, 3].each do |m|
            yield "  \002#{m[/.+/]}\017"
          end
          yield "  ... and more. check it: http://bit.ly/79d33W" if messages.size > 3
        end
      rescue Errno::ECONNREFUSED, Timeout::Error => e
        @log.error "Failed to get the latest revision of tig.rb from #{uri.host}: #{e.inspect}"
      end
    end
  end
end
