#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class SqlTableName 
    
    def initialize(name = "",prefix = "")
      @name = name
      @prefix = prefix
    end
    
    attr_accessor :name
    attr_accessor :prefix
    
    def to_s 
      return @name if @prefix == ""
      return _hx_str(@prefix) + "." + _hx_str(@name)
    end
    
  haxe_me ["coopy", "SqlTableName"]
  end

end
