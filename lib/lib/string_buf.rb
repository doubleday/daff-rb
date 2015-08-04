#!/usr/bin/env ruby
# encoding: utf-8

  class StringBuf 
    
    def initialize
      @b = ""
    end
    
    # protected - in ruby this doesn't play well with static/inline methods
    
    attr_accessor :b
    
    public
    
    attr_accessor :length
  haxe_me ["StringBuf"]
  end

