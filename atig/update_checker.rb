#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

module Atig
  module UpdateChecker
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

    def git?
      system('which git')
    end

    def latest
      unless git? then
        []
      else
        cs      = commits
        latest  = cs.first['id'][/^[0-9a-z]{40}$/]
        raise "github API changed?" unless latest

        if local_repos?(latest) then
          []
        else
          current  = cs.map {|i| i['id'] }.index(server_version)
          cs[0...current].map {|i| i['message'] }
        end
      end
    rescue Errno::ECONNREFUSED, Timeout::Error => e
      []
    end

    module_function :latest, :commits, :server_version, :local_repos?, :git?
  end
end

