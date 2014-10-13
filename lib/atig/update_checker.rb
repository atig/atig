# -*- mode:ruby; coding:utf-8 -*-

module Atig
  module UpdateChecker
    def commits
      uri = URI("https://api.github.com/repos/atig/atig/commits")
      http = Atig::Http.new
      res = http.http(uri).request http.req(:get, uri)
      JSON.parse(res.body)
    end

    def server_version
      @server_version ||= instance_eval {
        head = `git rev-parse HEAD 2>/dev/null`.chomp
        head.empty?? "unknown" : head
      }
    end

    def local_repos?(rev)
      system("git show #{rev} > /dev/null 2>&1")
    end

    def git_repos?
      File.exists? File.expand_path('../../../.git', __FILE__)
    end

    def git?
      system('which git > /dev/null 2>&1')
    end

    def latest
      unless git? then
        []
      else
        cs      = commits
        latest  = cs.first['sha'][/^[0-9a-z]{40}$/]
        raise "github API changed?" unless latest

        if local_repos?(latest) then
          []
        else
          current  = cs.map {|i| i['sha'] }.index(server_version)
          if current then
            cs[0...current]
          else
            cs
          end.map {|i| i['commit']['message'] }
        end
      end
    rescue TypeError, Errno::ECONNREFUSED, Timeout::Error
      []
    end

    module_function :latest, :commits, :server_version, :local_repos?, :git?, :git_repos?
  end
end
