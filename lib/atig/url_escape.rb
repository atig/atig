# -*- mode:ruby; coding:utf-8 -*-

require 'addressable'

class Hash
  # { f: "v" }    #=> "f=v"
  # { "f" => [1, 2] } #=> "f=1&f=2"
  # { "f" => "" }     #=> "f="
  # { "f" => nil }    #=> "f"
  def to_query_str separator = "&"
    inject([]) do |r, (k, v)|
      k = Addressable::URI.encode_component k.to_s
      (v.is_a?(Array) ? v : [v]).each do |i|
        if i.nil?
          r << k
        else
          r << "#{k}=#{Addressable::URI.encode_component i.to_s}"
        end
      end
      r
    end.join separator
  end
end

class String
  def ch?
    /\A[&#+!][^ \007,]{1,50}\z/ === self
  end

  def screen_name?
    /\A[A-Za-z0-9_]{1,15}\z/ === self
  end

  def encoding! enc
    return self unless respond_to? :force_encoding
    force_encoding enc
  end

  def rstrip_url
    	self.sub(%r{
    		(?: ( / [^/?#()]* (?: \( [^/?#()]* \) [^/?#()]* )* ) \) [^/?#()]*
    		  | \.
    		) \z
    	}x, "\\1")
  end

end
