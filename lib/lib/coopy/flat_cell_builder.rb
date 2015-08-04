#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class FlatCellBuilder 
    
    def initialize
    end
    
    # protected - in ruby this doesn't play well with static/inline methods
    
    attr_accessor :view
    attr_accessor :separator
    attr_accessor :conflict_separator
    
    public
    
    def need_separator 
      return true
    end
    
    def set_separator(separator)
      @separator = separator
    end
    
    def set_conflict_separator(separator)
      @conflict_separator = separator
    end
    
    def set_view(view)
      @view = view
    end
    
    def update(local,remote)
      return @view.to_datum(_hx_str(::Coopy::FlatCellBuilder.quote_for_diff(@view,local)) + _hx_str(@separator) + _hx_str(::Coopy::FlatCellBuilder.quote_for_diff(@view,remote)))
    end
    
    def conflict(parent,local,remote)
      return _hx_str(@view.to_s(parent)) + _hx_str(@conflict_separator) + _hx_str(@view.to_s(local)) + _hx_str(@conflict_separator) + _hx_str(@view.to_s(remote))
    end
    
    def marker(label)
      return @view.to_datum(label)
    end
    
    def links(unit)
      return @view.to_datum(unit.to_s)
    end
    
    def FlatCellBuilder.quote_for_diff(v,d)
      _nil = "NULL"
      return _nil if v.equals(d,nil)
      str = v.to_s(d)
      score = 0
      begin
        _g1 = 0
        _g = str.length
        while(_g1 < _g) 
          i = _g1
          _g1+=1
          break if (str[score].ord rescue nil) != 95
          score+=1
        end
      end
      str = "_" + _hx_str(str) if str[score..-1] == _nil
      return str
    end
    
  haxe_me ["coopy", "FlatCellBuilder"]
  end

end
