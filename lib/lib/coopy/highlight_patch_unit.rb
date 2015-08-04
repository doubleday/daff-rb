#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class HighlightPatchUnit 
    
    def initialize
      @add = false
      @rem = false
      @update = false
      @source_row = -1
      @source_row_offset = 0
      @source_prev_row = -1
      @source_next_row = -1
      @dest_row = -1
      @patch_row = -1
      @code = ""
    end
    
    attr_accessor :add
    attr_accessor :rem
    attr_accessor :update
    attr_accessor :code
    attr_accessor :source_row
    attr_accessor :source_row_offset
    attr_accessor :source_prev_row
    attr_accessor :source_next_row
    attr_accessor :dest_row
    attr_accessor :patch_row
    
    def to_s 
      return _hx_str(@code) + " patchRow " + _hx_str(@patch_row) + " sourceRows " + _hx_str(@source_prev_row) + "," + _hx_str(@source_row) + "," + _hx_str(@source_next_row) + " destRow " + _hx_str(@dest_row)
    end
    
  haxe_me ["coopy", "HighlightPatchUnit"]
  end

end
