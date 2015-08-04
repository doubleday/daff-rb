#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class Index 
    
    def initialize
      @items = {}
      @cols = Array.new
      @keys = Array.new
      @top_freq = 0
      @height = 0
    end
    
    attr_accessor :items
    attr_accessor :keys
    attr_accessor :top_freq
    attr_accessor :height
    
    protected
    
    attr_accessor :cols
    attr_accessor :v
    attr_accessor :indexed_table
    
    public
    
    def add_column(i)
      @cols.push(i)
    end
    
    def index_table(t)
      @indexed_table = t
      @keys[t.get_height - 1] = nil if @keys.length != t.get_height && t.get_height > 0
      begin
        _g1 = 0
        _g = t.get_height
        while(_g1 < _g) 
          i = _g1
          _g1+=1
          key = @keys[i]
          if key == nil 
            key = self.to_key(t,i)
            @keys[i] = key
          end
          item = @items[key]
          if item == nil 
            item = ::Coopy::IndexItem.new
            @items[key] = item
          end
          ct = nil
          begin
            item.lst = Array.new if item.lst == nil
            item.lst.push(i)
            ct = item.lst.length
          end
          @top_freq = ct if ct > @top_freq
        end
      end
      @height = t.get_height
    end
    
    def to_key(t,i)
      wide = ""
      @v = t.get_cell_view if @v == nil
      begin
        _g1 = 0
        _g = @cols.length
        while(_g1 < _g) 
          k = _g1
          _g1+=1
          d = t.get_cell(@cols[k],i)
          txt = @v.to_s(d)
          next if txt == nil || txt == "" || txt == "null" || txt == "undefined"
          wide += " // " if k > 0
          wide += txt
        end
      end
      return wide
    end
    
    def to_key_by_content(row)
      wide = ""
      begin
        _g1 = 0
        _g = @cols.length
        while(_g1 < _g) 
          k = _g1
          _g1+=1
          txt = row.get_row_string(@cols[k])
          next if txt == nil || txt == "" || txt == "null" || txt == "undefined"
          wide += " // " if k > 0
          wide += txt
        end
      end
      return wide
    end
    
    def get_table 
      return @indexed_table
    end
    
  haxe_me ["coopy", "Index"]
  end

end
