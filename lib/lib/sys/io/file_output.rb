#!/usr/bin/env ruby
# encoding: utf-8

module Sys
module Io
  class FileOutput < ::Haxe::Io::Output 
    
    def initialize(f)
      @__f = f
    end
    
    protected
    
    attr_accessor :__f
    
    public
    
     
    
    def write_byte(c)
      @__f.putc(c)
    end
     
    
    def write_bytes(b,p,l)
      s = b.get_string(p,l)
      r = @__f.write(s)
      raise hx_raise(::Haxe::Io::Error.custom("An error occurred")) if r < l
      return r
    end
    
  haxe_me ["sys", "io", "FileOutput"]
  end

end
end
