#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class TerminalDiffRender 
    
    def initialize
      @align_columns = true
    end
    
    protected
    
    attr_accessor :codes
    attr_accessor :t
    attr_accessor :csv
    attr_accessor :v
    attr_accessor :align_columns
    
    public
    
    def align_columns(enable)
      @align_columns = enable
    end
    
    def render(t)
      @csv = ::Coopy::Csv.new
      result = ""
      w = t.get_width
      h = t.get_height
      txt = ""
      @t = t
      @v = t.get_cell_view
      @codes = {}
      @codes["header"] = "\x1B[0;1m"
      @codes["spec"] = "\x1B[35;1m"
      @codes["add"] = "\x1B[32;1m"
      @codes["conflict"] = "\x1B[33;1m"
      @codes["modify"] = "\x1B[34;1m"
      @codes["remove"] = "\x1B[31;1m"
      @codes["minor"] = "\x1B[2m"
      @codes["done"] = "\x1B[0m"
      sizes = nil
      sizes = self.pick_sizes(t) if @align_columns
      begin
        _g = 0
        while(_g < h) 
          y = _g
          _g+=1
          begin
            _g1 = 0
            while(_g1 < w) 
              x = _g1
              _g1+=1
              txt += _hx_str(@codes["minor"]) + "," + _hx_str(@codes["done"]) if x > 0
              txt += self.get_text(x,y,true)
              if sizes != nil 
                bit = self.get_text(x,y,false)
                begin
                  _g3 = 0
                  _g2 = sizes[x] - bit.length
                  while(_g3 < _g2) 
                    i = _g3
                    _g3+=1
                    txt += " "
                  end
                end
              end
            end
          end
          txt += "\r\n"
        end
      end
      @t = nil
      @v = nil
      @csv = nil
      @codes = nil
      return txt
    end
    
    protected
    
    def get_text(x,y,color)
      val = @t.get_cell(x,y)
      cell = ::Coopy::DiffRender.render_cell(@t,@v,x,y)
      if color 
        code = nil
        code = @codes[cell.category] if cell.category != nil
        if cell.category_given_tr != nil 
          code_tr = @codes[cell.category_given_tr]
          code = code_tr if code_tr != nil
        end
        if code != nil 
          if cell.rvalue != nil 
            val = _hx_str(@codes["remove"]) + _hx_str(cell.lvalue) + _hx_str(@codes["modify"]) + _hx_str(cell.pretty_separator) + _hx_str(@codes["add"]) + _hx_str(cell.rvalue) + _hx_str(@codes["done"])
            val = _hx_str(@codes["conflict"]) + _hx_str(cell.pvalue) + _hx_str(@codes["modify"]) + _hx_str(cell.pretty_separator) + _hx_str(val.to_s) if cell.pvalue != nil
          else 
            val = cell.pretty_value
            val = _hx_str(code) + _hx_str(val.to_s) + _hx_str(@codes["done"])
          end
        end
      else 
        val = cell.pretty_value
      end
      return @csv.render_cell(@v,val)
    end
    
    def pick_sizes(t)
      w = t.get_width
      h = t.get_height
      v = t.get_cell_view
      csv = ::Coopy::Csv.new
      sizes = Array.new
      row = -1
      total = w - 1
      begin
        _g = 0
        while(_g < w) 
          x = _g
          _g+=1
          m = 0
          m2 = 0
          mmax = 0
          mmostmax = 0
          mmin = -1
          begin
            _g1 = 0
            while(_g1 < h) 
              y = _g1
              _g1+=1
              txt = self.get_text(x,y,false)
              row = y if txt == "@@" && row == -1
              len = txt.length
              mmin = len if y == row
              m += len
              m2 += len * len
              mmax = len if len > mmax
            end
          end
          mean = m / h
          stddev = Math.sqrt(m2 / h - mean * mean)
          most = (mean + stddev * 2 + 0.5).to_i
          begin
            _g11 = 0
            while(_g11 < h) 
              y1 = _g11
              _g11+=1
              txt1 = self.get_text(x,y1,false)
              len1 = txt1.length
              if len1 <= most 
                mmostmax = len1 if len1 > mmostmax
              end
            end
          end
          full = mmax
          most = mmostmax
          if mmin != -1 
            most = mmin if most < mmin
          end
          sizes.push(most)
          total += most
        end
      end
      return nil if total > 130
      return sizes
    end
    
  haxe_me ["coopy", "TerminalDiffRender"]
  end

end
