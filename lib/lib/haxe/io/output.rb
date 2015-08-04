#!/usr/bin/env ruby
# encoding: utf-8

module Haxe
module Io
  class Output 
    
    def write_byte(c)
      raise hx_raise("Not implemented")
    end
    
    def write_bytes(s,pos,len)
      k = len
      b = s.b
      raise hx_raise(::Haxe::Io::Error.outside_bounds) if pos < 0 || len < 0 || pos + len > s.length
      while(k > 0) 
        self.write_byte(b[pos])
        pos+=1
        k-=1
      end
      return len
    end
    
    def write_full_bytes(s,pos,len)
      while(len > 0) 
        k = self.write_bytes(s,pos,len)
        pos += k
        len -= k
      end
    end
    
    def write_string(s)
      b = ::Haxe::Io::Bytes.of_string(s)
      self.write_full_bytes(b,0,b.length)
    end
    
  haxe_me ["haxe", "io", "Output"]
  end

end
end
