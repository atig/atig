#!/usr/bin/env ruby
# -*- mode:ruby; coding:utf-8 -*-
require 'atig/command/command'
require 'atig/search'

module Atig
  module Command
    class Search < Atig::Command::Command
      def command_name; %w(search s) end

      def action(target, mesg, command, args)
        if args.empty?
          yield "/me #{command} [option...] blah blah"
          return
        end

        q = mesg.sub(/^#{command}\s+/, '')
        opts = {}
        while /^:(?:(lang)=(\w+))/ =~ args.first
           opts[$1] = $2
           q.sub!(/^#{args.first}\W+/, "")
           args.shift
        end

        s = Atig::Search.new
        res = s.search(q, opts)

        if res['results'].empty?
          yield "\"#{q}\": not found. options=#{opts.inspect} (#{res['completed_in']} sec.)"
          return
        end

        res['results'].reverse.each do |tw|
          # TODO: 検索結果にも tid/sid を振りたい
          # TODO: Info.user() する度に各ユーザーの statuses/home_timeline にアクセスして API Limt がヤバい
          Info.user(db, api, tw['from_user']) do |user|
            entry = TwitterStruct.make('user'   => user,
                                       'status' => { 'text' =>
                                         Net::IRC.ctcp_encode("#{tw['text']} (#{tw['created_at']})") })
            gateway[target].message entry, Net::IRC::Constants::NOTICE
          end
        end
      end
    end
  end
end
