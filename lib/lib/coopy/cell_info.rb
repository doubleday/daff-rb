#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class CellInfo 
    
    def initialize
    end
    
    attr_accessor :raw
    attr_accessor :value
    attr_accessor :pretty_value
    attr_accessor :category
    attr_accessor :category_given_tr
    attr_accessor :separator
    attr_accessor :pretty_separator
    attr_accessor :updated
    attr_accessor :conflicted
    attr_accessor :pvalue
    attr_accessor :lvalue
    attr_accessor :rvalue
    
    def to_s 
      return @value if !@updated
      return _hx_str(@lvalue) + "::" + _hx_str(@rvalue) if !@conflicted
      return _hx_str(@pvalue) + "||" + _hx_str(@lvalue) + "::" + _hx_str(@rvalue)
    end
    
  haxe_me ["coopy", "CellInfo"]
  end

end
