require 'json'
require 'atig/http'
require 'atig/url_escape'

module Atig
  class Search
    def search(query, options = {})
      search = URI("http://search.twitter.com/search.json")
      search.path = "/search.json"
      params = options; options[:q] = query
      search.query = options.to_query_str
      http = Http.new nil
      req = http.req(:get, search)
      res = http.http(search, 5, 10).request(req)
      res = JSON.parse(res.body)
    rescue Errno::ETIMEDOUT, JSON::ParserError, IOError, Timeout::Error, Errno::ECONNRESET => e
      @log.error e
      text
    end
  end
end
