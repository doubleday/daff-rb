#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class Unit 
    
    def initialize(l = -2,r = -2,p = -2)
      @l = l
      @r = r
      @p = p
    end
    
    attr_accessor :l
    attr_accessor :r
    attr_accessor :p
    
    def lp 
      if @p == -2 
        return @l
      else 
        return @p
      end
    end
    
    def to_s 
      return _hx_str(::Coopy::Unit.describe(@p)) + "|" + _hx_str(::Coopy::Unit.describe(@l)) + ":" + _hx_str(::Coopy::Unit.describe(@r)) if @p >= -1
      return _hx_str(::Coopy::Unit.describe(@l)) + ":" + _hx_str(::Coopy::Unit.describe(@r))
    end
    
    def from_string(txt)
      txt += "]"
      at = 0
      begin
        _g1 = 0
        _g = txt.length
        while(_g1 < _g) 
          i = _g1
          _g1+=1
          ch = (txt[i].ord rescue nil)
          if ch >= 48 && ch <= 57 
            at *= 10
            at += ch - 48
          elsif ch == 45 
            at = -1
          elsif ch == 124 
            @p = at
            at = 0
          elsif ch == 58 
            @l = at
            at = 0
          elsif ch == 93 
            @r = at
            return true
          end
        end
      end
      return false
    end
    
    # protected - in ruby this doesn't play well with static/inline methods
    
    def Unit.describe(i)
      if i >= 0 
        return "" + _hx_str(i)
      else 
        return "-"
      end
    end
    
  haxe_me ["coopy", "Unit"]
  end

end
