#!/usr/bin/env ruby
# encoding: utf-8

module Sys
module Io
  class FileHandle
    ISENUM__ = true
    attr_accessor :tag
    attr_accessor :index
    attr_accessor :params
    def initialize(t,index,p = nil ) @tag = t; @index = index; @params = p; end
    
    CONSTRUCTS__ = []
    def ==(a) (!a.nil?) && (a.respond_to? 'ISENUM__') && a.tag === @tag && a.index === @index && a.params == @params end
  end

end
end
