#!/usr/bin/env ruby
# encoding: utf-8

  class List 
    
    def initialize
      @length = 0
    end
    
    # protected - in ruby this doesn't play well with static/inline methods
    
    attr_accessor :h
    attr_accessor :q
    
    public
    
    attr_accessor :length
    
    def add(item)
      x = [item]
      if @h == nil 
        @h = x
      else 
        @q[1] = x
      end
      @q = x
      @length+=1
    end
    
    def iterator 
      return ::X_List::ListIterator.new(@h)
    end
    
  haxe_me ["List"]
  end

