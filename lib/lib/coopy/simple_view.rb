#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class SimpleView 
    
    def initialize
    end
    
    def to_s(d)
      return nil if d == nil
      return "" + _hx_str(d.to_s)
    end
    
    def equals(d1,d2)
      return true if d1 == nil && d2 == nil
      return true if d1 == nil && "" + _hx_str(d2.to_s) == ""
      return true if "" + _hx_str(d1.to_s) == "" && d2 == nil
      return "" + _hx_str(d1.to_s) == "" + _hx_str(d2.to_s)
    end
    
    def to_datum(x)
      return x
    end
    
    def make_hash 
      return {}
    end
    
    def hash_set(h,str,d)
      hh = h
      begin
        value = d
        begin
          value1 = value
          hh[str] = value1
        end
      end
    end
    
    def hash_exists(h,str)
      hh = h
      return hh.include?(str)
    end
    
    def hash_get(h,str)
      hh = h
      return hh[str]
    end
    
    def is_hash(h)
      return h.respond_to? :keys
    end
    
  haxe_me ["coopy", "SimpleView"]
  end

end
