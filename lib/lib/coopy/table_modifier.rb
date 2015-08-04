#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class TableModifier 
    
    def initialize(t)
      @t = t
    end
    
    protected
    
    attr_accessor :t
    
    public
    
    def remove_column(at)
      fate = []
      begin
        _g1 = 0
        _g = @t.get_width
        while(_g1 < _g) 
          i = _g1
          _g1+=1
          if i < at 
            fate.push(i)
          elsif i > at 
            fate.push(i - 1)
          else 
            fate.push(-1)
          end
        end
      end
      return @t.insert_or_delete_columns(fate,@t.get_width - 1)
    end
    
  haxe_me ["coopy", "TableModifier"]
  end

end
