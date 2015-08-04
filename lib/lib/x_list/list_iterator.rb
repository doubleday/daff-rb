#!/usr/bin/env ruby
# encoding: utf-8

module X_List
  class ListIterator 
    
    def initialize(head)
      @head = head
      @val = nil
    end
    
    # protected - in ruby this doesn't play well with static/inline methods
    
    attr_accessor :head
    attr_accessor :val
    
    public
    
    def has_next 
      return @head != nil
    end
    
    def _next 
      @val = @head[0]
      @head = @head[1]
      return @val
    end
    
  haxe_me ["_List", "ListIterator"]
  end

end
