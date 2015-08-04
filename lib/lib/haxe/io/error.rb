#!/usr/bin/env ruby
# encoding: utf-8

module Haxe
module Io
  class Error
    ISENUM__ = true
    attr_accessor :tag
    attr_accessor :index
    attr_accessor :params
    def initialize(t,index,p = nil ) @tag = t; @index = index; @params = p; end
    
    def Error.blocked() Error.new("Blocked",0) end
    def Error.custom(e)  Error.new("Custom",3,[e]) end
    def Error.outside_bounds() Error.new("OutsideBounds",2) end
    def Error.overflow() Error.new("Overflow",1) end
    CONSTRUCTS__ = ["Blocked","Overflow","OutsideBounds","Custom"]
    def ==(a) (!a.nil?) && (a.respond_to? 'ISENUM__') && a.tag === @tag && a.index === @index && a.params == @params end
  end

end
end
