#! /opt/local/bin/ruby -w
# -*- mode:ruby; coding:utf-8 -*-

class SizedArray
  Roman = %w[
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

  def initialize(size)
    @size = size
    @index = 0
    @xs = []
    @seq = Roman
    @tid = {}
  end

  def include?(id)
    @xs.any?{|item| item.id == id }
  end

  def index(s)
    @xs.index(s)
  end

  def generate(n)
    ret = []
    begin
      n, r = n.divmod(@seq.size)
      ret << @seq[r]
    end while n > 0
    ret.reverse.join #.gsub(/n(?=[bmp])/, "m")
  end

  def push(status)
    tid = generate @index
    status[:tid] = tid
    @tid[tid] = @xs[@index] = status
    @index = (@index + 1) % @size
  end
  alias_method :<<, :push

  def [](tid)
    @tid[tid]
  end
end
