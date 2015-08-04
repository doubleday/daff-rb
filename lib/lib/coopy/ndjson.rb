#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class Ndjson 
    
    def initialize(tab)
      @tab = tab
      @view = tab.get_cell_view
      @header_row = 0
    end
    
    protected
    
    attr_accessor :tab
    attr_accessor :view
    attr_accessor :columns
    attr_accessor :header_row
    
    public
    
    def render_row(r)
      row = {}
      begin
        _g1 = 0
        _g = @tab.get_width
        while(_g1 < _g) 
          c = _g1
          _g1+=1
          key = @view.to_s(@tab.get_cell(c,@header_row))
          key = "@:@" if c == 0 && @header_row == 1
          begin
            value = @tab.get_cell(c,r)
            begin
              value1 = value
              row[key] = value1
            end
          end
        end
      end
      return ::Haxe::Format::JsonPrinter._print(row,nil,nil)
    end
    
    def render 
      txt = ""
      offset = 0
      return txt if @tab.get_height == 0
      return txt if @tab.get_width == 0
      offset = 1 if @tab.get_cell(0,0) == "@:@"
      @header_row = offset
      begin
        _g1 = @header_row + 1
        _g = @tab.get_height
        while(_g1 < _g) 
          r = _g1
          _g1+=1
          txt += self.render_row(r)
          txt += "\n"
        end
      end
      return txt
    end
    
    def add_row(r,txt)
      json = ::Haxe::Format::JsonParser.new(txt).parse_rec
      @columns = {} if @columns == nil
      w = @tab.get_width
      h = @tab.get_height
      resize = false
      begin
        _g = 0
        _g1 = Reflect.fields(json)
        while(_g < _g1.length) 
          name = _g1[_g]
          _g+=1
          if !@columns.include?(name) 
            @columns[name] = w
            w+=1
            resize = true
          end
        end
      end
      if r >= h 
        h = r + 1
        resize = true
      end
      @tab.resize(w,h) if resize
      begin
        _g2 = 0
        _g11 = Reflect.fields(json)
        while(_g2 < _g11.length) 
          name1 = _g11[_g2]
          _g2+=1
          v = Reflect.field(json,name1)
          c = @columns[name1]
          @tab.set_cell(c,r,v)
        end
      end
    end
    
    def add_header_row(r)
      names = ::Rb::RubyIterator.new(@columns.keys)
      _it = names
      while(_it.has_next) do
        n = _it._next
        @tab.set_cell(@columns[n],r,@view.to_datum(n))
      end
    end
    
    def parse(txt)
      @columns = nil
      rows = txt.split("\n")
      h = rows.length
      if h == 0 
        @tab.clear
        return
      end
      h-=1 if rows[h - 1] == ""
      begin
        _g = 0
        while(_g < h) 
          i = _g
          _g+=1
          at = h - i - 1
          self.add_row(at + 1,rows[at])
        end
      end
      self.add_header_row(0)
    end
    
  haxe_me ["coopy", "Ndjson"]
  end

end
