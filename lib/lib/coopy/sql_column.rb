#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class SqlColumn 
    
    def initialize
    end
    
    attr_accessor :name
    attr_accessor :primary
    
    def get_name 
      return @name
    end
    
    def is_primary_key 
      return @primary
    end
    
    def to_s 
      return _hx_str((((@primary) ? "*" : ""))) + _hx_str(@name)
    end
    
    def SqlColumn.by_name_and_primary_key(name,primary)
      result = ::Coopy::SqlColumn.new
      result.name = name
      result.primary = primary
      return result
    end
    
  haxe_me ["coopy", "SqlColumn"]
  end

end
