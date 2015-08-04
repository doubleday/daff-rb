#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class SimpleTable 
    
    def initialize(w,h)
      @data = {}
      @w = w
      @h = h
    end
    
    # protected - in ruby this doesn't play well with static/inline methods
    
    attr_accessor :data
    attr_accessor :w
    attr_accessor :h
    
    public
    
    def get_table 
      return self
    end
    
    def height() get_height end
    def height=(__v) @height = __v end
    def width() get_width end
    def width=(__v) @width = __v end
    
    def get_width 
      return @w
    end
    
    def get_height 
      return @h
    end
    
    def get_cell(x,y)
      return @data[x + y * @w]
    end
    
    def set_cell(x,y,c)
      value = c
      begin
        value1 = value
        @data[x + y * @w] = value1
      end
    end
    
    def to_s 
      return ::Coopy::SimpleTable.table_to_string(self)
    end
    
    def get_cell_view 
      return ::Coopy::SimpleView.new
    end
    
    def is_resizable 
      return true
    end
    
    def resize(w,h)
      @w = w
      @h = h
      return true
    end
    
    def clear 
      @data = {}
    end
    
    def insert_or_delete_rows(fate,hfate)
      data2 = {}
      begin
        _g1 = 0
        _g = fate.length
        while(_g1 < _g) 
          i = _g1
          _g1+=1
          j = fate[i]
          if j != -1 
            _g3 = 0
            _g2 = @w
            while(_g3 < _g2) 
              c = _g3
              _g3+=1
              idx = i * @w + c
              if @data.include?(idx) 
                value = @data[idx]
                begin
                  value1 = value
                  data2[j * @w + c] = value1
                end
              end
            end
          end
        end
      end
      @h = hfate
      @data = data2
      return true
    end
    
    def insert_or_delete_columns(fate,wfate)
      data2 = {}
      begin
        _g1 = 0
        _g = fate.length
        while(_g1 < _g) 
          i = _g1
          _g1+=1
          j = fate[i]
          if j != -1 
            _g3 = 0
            _g2 = @h
            while(_g3 < _g2) 
              r = _g3
              _g3+=1
              idx = r * @w + i
              if @data.include?(idx) 
                value = @data[idx]
                begin
                  value1 = value
                  data2[r * wfate + j] = value1
                end
              end
            end
          end
        end
      end
      @w = wfate
      @data = data2
      return true
    end
    
    def trim_blank 
      return true if @h == 0
      h_test = @h
      h_test = 3 if h_test >= 3
      view = self.get_cell_view
      space = view.to_datum("")
      more = true
      while(more) 
        begin
          _g1 = 0
          _g = self.get_width
          while(_g1 < _g) 
            i = _g1
            _g1+=1
            c = self.get_cell(i,@h - 1)
            if !(view.equals(c,space) || c == nil) 
              more = false
              break
            end
          end
        end
        @h-=1 if more
      end
      more = true
      nw = @w
      while(more) 
        break if @w == 0
        begin
          _g2 = 0
          while(_g2 < h_test) 
            i1 = _g2
            _g2+=1
            c1 = self.get_cell(nw - 1,i1)
            if !(view.equals(c1,space) || c1 == nil) 
              more = false
              break
            end
          end
        end
        nw-=1 if more
      end
      return true if nw == @w
      data2 = {}
      begin
        _g3 = 0
        while(_g3 < nw) 
          i2 = _g3
          _g3+=1
          begin
            _g21 = 0
            _g11 = @h
            while(_g21 < _g11) 
              r = _g21
              _g21+=1
              idx = r * @w + i2
              if @data.include?(idx) 
                value = @data[idx]
                begin
                  value1 = value
                  data2[r * nw + i2] = value1
                end
              end
            end
          end
        end
      end
      @w = nw
      @data = data2
      return true
    end
    
    def get_data 
      return nil
    end
    
    def clone 
      result = ::Coopy::SimpleTable.new(self.get_width,self.get_height)
      begin
        _g1 = 0
        _g = self.get_height
        while(_g1 < _g) 
          i = _g1
          _g1+=1
          begin
            _g3 = 0
            _g2 = self.get_width
            while(_g3 < _g2) 
              j = _g3
              _g3+=1
              result.set_cell(j,i,self.get_cell(j,i))
            end
          end
        end
      end
      return result
    end
    
    def SimpleTable.table_to_string(tab)
      x = ""
      begin
        _g1 = 0
        _g = tab.get_height
        while(_g1 < _g) 
          i = _g1
          _g1+=1
          begin
            _g3 = 0
            _g2 = tab.get_width
            while(_g3 < _g2) 
              j = _g3
              _g3+=1
              x += " " if j > 0
              begin
                s = tab.get_cell(j,i)
                x += s.to_s
              end
            end
          end
          x += "\n"
        end
      end
      return x
    end
    
    def SimpleTable.table_is_similar(tab1,tab2)
      return false if tab1.get_width != tab2.get_width
      return false if tab1.get_height != tab2.get_height
      v = tab1.get_cell_view
      begin
        _g1 = 0
        _g = tab1.get_height
        while(_g1 < _g) 
          i = _g1
          _g1+=1
          begin
            _g3 = 0
            _g2 = tab1.get_width
            while(_g3 < _g2) 
              j = _g3
              _g3+=1
              return false if !v.equals(tab1.get_cell(j,i),tab2.get_cell(j,i))
            end
          end
        end
      end
      return true
    end
    
  haxe_me ["coopy", "SimpleTable"]
  end

end
