require "net/https"
require 'atig/util'

module Atig
  class Http
    include Util

    @@proxy = nil
    def self.proxy=(proxy)
      if proxy =~ /\A(?:([^:@]+)(?::([^@]+))?@)?([^:]+)(?::(\d+))?\z/ then
        @@proxy = OpenStruct.new({
                                   :user => $1,
                                   :password => $2,
                                   :address => $3,
                                   :port => $4.to_i,
                                 })
      end
    end

    def initialize(logger=nil)
      @log = logger
      @cert_store = OpenSSL::X509::Store.new
      @cert_store.set_default_paths
    end

    def server_name
      "twittergw"
    end

    def server_version
      @server_version ||= instance_eval {
        head = `git rev-parse HEAD 2>/dev/null`.chomp
        head.empty?? "unknown" : head
      }
    end

    def http(uri, open_timeout = nil, read_timeout = 60)
      http = case
             when @@proxy
               Net::HTTP.new(uri.host, uri.port, @@proxy.address, @@proxy.port,
                             @@proxy.user, @@proxy.password)
             when ENV["HTTP_PROXY"], ENV["http_proxy"]
               proxy = URI(ENV["HTTP_PROXY"] || ENV["http_proxy"])
               Net::HTTP.new(uri.host, uri.port, proxy.host, proxy.port,
                             proxy.user, proxy.password)
             else
               Net::HTTP.new(uri.host, uri.port)
             end
      http.open_timeout = open_timeout if open_timeout # nil by default
      http.read_timeout = read_timeout if read_timeout # 60 by default
      if uri.is_a? URI::HTTPS
        http.use_ssl     = true
        http.cert_store = @cert_store
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      end
      http
    rescue => e
      log(:error, e) if @log
    end

    def req(method, uri, header = {}, credentials = nil)
      accepts = ["*/*"]
      types   = { "json" => "application/json", "txt" => "text/plain" }
      ext     = uri.path[/[^.]+\z/]
      accepts.unshift types[ext] if types.key?(ext)
      user_agent = "#{self.class}/#{server_version} (#{File.basename(__FILE__)}; net-irc) Ruby/#{RUBY_VERSION} (#{RUBY_PLATFORM})"

      header["User-Agent"]      ||= user_agent
      header["Accept"]          ||= accepts.join(",")
      header["Accept-Charset"]  ||= "UTF-8,*;q=0.0" if ext != "json"

      req = case method.to_s.downcase.to_sym
            when :get
              Net::HTTP::Get.new    uri.request_uri, header
            when :head
              Net::HTTP::Head.new   uri.request_uri, header
            when :post
              Net::HTTP::Post.new   uri.path,        header
            when :put
              Net::HTTP::Put.new    uri.path,        header
            when :delete
              Net::HTTP::Delete.new uri.request_uri, header
            else # raise ""
            end
      if req.request_body_permitted?
        req["Content-Type"] ||= "application/x-www-form-urlencoded"
        req.body = uri.query
      end
      req.basic_auth(*credentials) if credentials
      req
    rescue => e
      log(:error, e) if @log
    end
  end
end
