#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class IndexItem 
    
    def initialize
    end
    
    # protected - in ruby this doesn't play well with static/inline methods
    
    attr_accessor :lst
    
    public
    
    def add(i)
      @lst = Array.new if @lst == nil
      @lst.push(i)
      return @lst.length
    end
    
    def length 
      return @lst.length
    end
    
    def value 
      return @lst[0]
    end
    
  haxe_me ["coopy", "IndexItem"]
  end

end
