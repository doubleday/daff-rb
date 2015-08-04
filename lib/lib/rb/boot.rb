#!/usr/bin/env ruby
# encoding: utf-8

module Rb
  class Boot 
    
    # protected - in ruby this doesn't play well with static/inline methods
    
    def Boot.__trace(v,i)
      if i != nil 
        puts "#{v} #{i.inspect}"
      else 
        puts v
      end
    end
    
  haxe_me ["rb", "Boot"]
  end

end
