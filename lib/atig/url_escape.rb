# -*- mode:ruby; coding:utf-8 -*-

class Hash
  # { f: "v" }    #=> "f=v"
  # { "f" => [1, 2] } #=> "f=1&f=2"
  # { "f" => "" }     #=> "f="
  # { "f" => nil }    #=> "f"
  def to_query_str separator = "&"
    Atig::UrlEscape.encode_www_form(self, separator: separator)
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

module Atig
  module UrlEscape
    tblencwwwcomp_ = ::URI::TBLENCWWWCOMP_.dup
    tblencwwwcomp_[-' '] = -'%20'
    TBLENCWWWCOMP_ = tblencwwwcomp_.freeze

    def self.encode_www_form_component(str, enc=nil)
      str = str.to_s.dup
      if str.encoding != Encoding::ASCII_8BIT
        if enc && enc != Encoding::ASCII_8BIT
          str.encode!(Encoding::UTF_8, invalid: :replace, undef: :replace)
          str.encode!(enc, fallback: ->(x){"&##{x.ord};"})
        end
        str.force_encoding(Encoding::ASCII_8BIT)
      end
      str.gsub!(/[^~\-.0-9A-Z_a-z]/, TBLENCWWWCOMP_)
      str.force_encoding(Encoding::US_ASCII)
    end

    def self.encode_www_form(enum, enc=nil, separator: -'&')
      enum.map do |k,v|
        if v.nil?
          encode_www_form_component(k, enc)
        elsif v.respond_to?(:to_ary)
          v.to_ary.map do |w|
            str = encode_www_form_component(k, enc)
            unless w.nil?
              str << '='
              str << encode_www_form_component(w, enc)
            end
          end.join(separator)
        else
          str = encode_www_form_component(k, enc)
          str << '='
          str << encode_www_form_component(v, enc)
        end
      end.join(separator)
    end
  end
end

module URI
  def rstrip str
		str.sub(%r{
			(?: ( / [^/?#()]* (?: \( [^/?#()]* \) [^/?#()]* )* ) \) [^/?#()]*
			  | \.
			) \z
		}x, "\\1")
  end
end
