module Atig
  module Option
    def self.parse(str)
      real, *opts = str.split(" ")
      opts = opts.inject({}) do |r, i|
        key, value = i.split("=", 2)

        r.update key => parse_value(value)
      end
      [ real, OpenStruct.new(opts)]
    end

    def self.parse_value(value)
      case value
      when nil, /\Atrue\z/          then true
      when /\Afalse\z/              then false
      when /\A\d+\z/                then value.to_i
      when /\A(?:\d+\.\d*|\.\d+)\z/ then value.to_f
      else                               value
      end
    end
  end
end
