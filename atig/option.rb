module Atig
  module Option
    def self.parse(str)
      real, *opts = str.split(" ")
      opts = opts.inject({}) do |r, i|
        key, value = i.split("=", 2)

        r.update key => case value
                        when nil                      then true
                        when /\A\d+\z/                then value.to_i
                        when /\A(?:\d+\.\d*|\.\d+)\z/ then value.to_f
                        else                               value
                        end
      end
      [ real, OpenStruct.new(opts)]
    end
  end
end
