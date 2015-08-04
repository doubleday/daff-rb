#!/usr/bin/env ruby
# encoding: utf-8

module Haxe
module Io
  class BytesOutput < ::Haxe::Io::Output 
    
    # protected - in ruby this doesn't play well with static/inline methods
    
    attr_accessor :b
    
    public
    
    attr_accessor :length 
    
    def write_byte(c)
      @b.b.concat(c)
    end
     
    
    def write_bytes(buf,pos,len)
      begin
        raise hx_raise(::Haxe::Io::Error.outside_bounds) if pos < 0 || len < 0 || pos + len > buf.length
        @b.b += buf.b.byteslice(pos,len)
      end
      return len
    end
    
  haxe_me
  end

end
end
