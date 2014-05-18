# -*- mode:ruby; coding:utf-8 -*-

class Hash
  # { f: "v" }    #=> "f=v"
  # { "f" => [1, 2] } #=> "f=1&f=2"
  # { "f" => "" }     #=> "f="
  # { "f" => nil }    #=> "f"
  def to_query_str separator = "&"
    inject([]) do |r, (k, v)|
      k = URI.encode_component k.to_s
      (v.is_a?(Array) ? v : [v]).each do |i|
        if i.nil?
          r << k
        else
          r << "#{k}=#{URI.encode_component i.to_s}"
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
end

module URI::Escape
  alias :_orig_escape :escape

  if defined? ::RUBY_REVISION and RUBY_REVISION < 24544
		# URI.escape("あ１") #=> "%E3%81%82\xEF\xBC\x91"
    # URI("file:///４")  #=> #<URI::Generic:0x9d09db0 URL:file:/４>
    #   "\\d" -> "[0-9]" for Ruby 1.9
    def escape str, unsafe = %r{[^-_.!~*'()a-zA-Z0-9;/?:@&=+$,\[\]]} #'
      _orig_escape(str, unsafe)
    end
    alias :encode :escape
  end

  def encode_component(str, unsafe = ::OAuth::RESERVED_CHARACTERS)
    _orig_escape(str, unsafe).tr(" ", "+")
  end

  def rstrip str
		str.sub(%r{
			(?: ( / [^/?#()]* (?: \( [^/?#()]* \) [^/?#()]* )* ) \) [^/?#()]*
			  | \.
			) \z
		}x, "\\1")
  end
end
