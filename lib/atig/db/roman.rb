# -*- mode:ruby; coding:utf-8 -*-

module Atig
  module Db
    class Roman
      Seq = %w[
	  a   i   u   e   o  ka  ki  ku  ke  ko  sa shi  su  se  so
	 ta chi tsu  te  to  na  ni  nu  ne  no  ha  hi  fu  he  ho
	 ma  mi  mu  me  mo  ya      yu      yo  ra  ri  ru  re  ro
	 wa              wo   n
	 ga  gi  gu  ge  go  za  ji  zu  ze  zo  da          de  do
	 ba  bi  bu  be  bo  pa  pi  pu  pe  po
	kya     kyu     kyo sha     shu     sho cha     chu     cho
	nya     nyu     nyo hya     hyu     hyo mya     myu     myo
	rya     ryu     ryo
	gya     gyu     gyo  ja      ju      jo bya     byu     byo
	pya     pyu     pyo
      ].freeze

      def make(n)
        ret = []
        begin
          n, r = n.divmod(Seq.size)
          ret << Seq[r]
        end while n > 0
        ret.reverse.join
      end
    end
  end
end
