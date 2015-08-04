#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class Ordering 
    
    def initialize
      @order = Array.new
      @ignore_parent = false
    end
    
    protected
    
    attr_accessor :order
    attr_accessor :ignore_parent
    
    public
    
    def add(l,r,p = -2)
      p = -2 if @ignore_parent
      @order.push(::Coopy::Unit.new(l,r,p))
    end
    
    def get_list 
      return @order
    end
    
    def to_s 
      txt = ""
      begin
        _g1 = 0
        _g = @order.length
        while(_g1 < _g) 
          i = _g1
          _g1+=1
          txt += ", " if i > 0
          txt += @order[i].to_s
        end
      end
      return txt
    end
    
    def ignore_parent 
      @ignore_parent = true
    end
    
  haxe_me ["coopy", "Ordering"]
  end

end
