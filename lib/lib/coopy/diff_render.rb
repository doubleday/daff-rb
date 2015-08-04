#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class DiffRender 
    
    def initialize
      @text_to_insert = Array.new
      @open = false
      @pretty_arrows = true
    end
    
    # protected - in ruby this doesn't play well with static/inline methods
    
    attr_accessor :text_to_insert
    attr_accessor :td_open
    attr_accessor :td_close
    attr_accessor :open
    attr_accessor :pretty_arrows
    attr_accessor :section
    
    public
    
    def use_pretty_arrows(flag)
      @pretty_arrows = flag
    end
    
    # protected - in ruby this doesn't play well with static/inline methods
    
    def insert(str)
      @text_to_insert.push(str)
    end
    
    def begin_table 
      self.insert("<table>\n")
      @section = nil
    end
    
    def set_section(str)
      return if str == @section
      if @section != nil 
        self.insert("</t")
        self.insert(@section)
        self.insert(">\n")
      end
      @section = str
      if @section != nil 
        self.insert("<t")
        self.insert(@section)
        self.insert(">\n")
      end
    end
    
    def begin_row(mode)
      @td_open = "<td"
      @td_close = "</td>"
      row_class = ""
      if mode == "header" 
        @td_open = "<th"
        @td_close = "</th>"
      end
      row_class = mode
      tr = "<tr>"
      tr = "<tr class=\"" + _hx_str(row_class) + "\">" if row_class != ""
      self.insert(tr)
    end
    
    def insert_cell(txt,mode)
      cell_decorate = ""
      cell_decorate = " class=\"" + _hx_str(mode) + "\"" if mode != ""
      self.insert(_hx_str(@td_open) + _hx_str(cell_decorate) + ">")
      self.insert(txt)
      self.insert(@td_close)
    end
    
    def end_row 
      self.insert("</tr>\n")
    end
    
    def end_table 
      self.set_section(nil)
      self.insert("</table>\n")
    end
    
    public
    
    def html 
      return @text_to_insert.join("")
    end
    
    def to_s 
      return self.html
    end
    
    def render(tab)
      return self if tab.get_width == 0 || tab.get_height == 0
      render = self
      render.begin_table
      change_row = -1
      cell = ::Coopy::CellInfo.new
      view = tab.get_cell_view
      corner = view.to_s(tab.get_cell(0,0))
      off = nil
      if corner == "@:@" 
        off = 1
      else 
        off = 0
      end
      if off > 0 
        return self if tab.get_width <= 1 || tab.get_height <= 1
      end
      begin
        _g1 = 0
        _g = tab.get_height
        while(_g1 < _g) 
          row = _g1
          _g1+=1
          open = false
          txt = view.to_s(tab.get_cell(off,row))
          txt = "" if txt == nil
          ::Coopy::DiffRender.examine_cell(off,row,view,txt,"",txt,corner,cell,off)
          row_mode = cell.category
          change_row = row if row_mode == "spec"
          if row_mode == "header" || row_mode == "spec" || row_mode == "index" 
            self.set_section("head")
          else 
            self.set_section("body")
          end
          render.begin_row(row_mode)
          begin
            _g3 = 0
            _g2 = tab.get_width
            while(_g3 < _g2) 
              c = _g3
              _g3+=1
              ::Coopy::DiffRender.examine_cell(c,row,view,tab.get_cell(c,row),((change_row >= 0) ? view.to_s(tab.get_cell(c,change_row)) : ""),txt,corner,cell,off)
              render.insert_cell(((@pretty_arrows) ? cell.pretty_value : cell.value),cell.category_given_tr)
            end
          end
          render.end_row
        end
      end
      render.end_table
      return self
    end
    
    def sample_css 
      return ".highlighter .add { \n  background-color: #7fff7f;\n}\n\n.highlighter .remove { \n  background-color: #ff7f7f;\n}\n\n.highlighter td.modify { \n  background-color: #7f7fff;\n}\n\n.highlighter td.conflict { \n  background-color: #f00;\n}\n\n.highlighter .spec { \n  background-color: #aaa;\n}\n\n.highlighter .move { \n  background-color: #ffa;\n}\n\n.highlighter .null { \n  color: #888;\n}\n\n.highlighter table { \n  border-collapse:collapse;\n}\n\n.highlighter td, .highlighter th {\n  border: 1px solid #2D4068;\n  padding: 3px 7px 2px;\n}\n\n.highlighter th, .highlighter .header { \n  background-color: #aaf;\n  font-weight: bold;\n  padding-bottom: 4px;\n  padding-top: 5px;\n  text-align:left;\n}\n\n.highlighter tr.header th {\n  border-bottom: 2px solid black;\n}\n\n.highlighter tr.index td, .highlighter .index, .highlighter tr.header th.index {\n  background-color: white;\n  border: none;\n}\n\n.highlighter .gap {\n  color: #888;\n}\n\n.highlighter td {\n  empty-cells: show;\n}\n"
    end
    
    def complete_html 
      @text_to_insert.insert(0,"<!DOCTYPE html>\n<html>\n<head>\n<meta charset='utf-8'>\n<style TYPE='text/css'>\n")
      @text_to_insert.insert(1,self.sample_css)
      @text_to_insert.insert(2,"</style>\n</head>\n<body>\n<div class='highlighter'>\n")
      @text_to_insert.push("</div>\n</body>\n</html>\n")
    end
    
    def DiffRender.examine_cell(x,y,view,raw,vcol,vrow,vcorner,cell,offset = 0)
      nested = view.is_hash(raw)
      value = nil
      value = view.to_s(raw) if !nested
      cell.category = ""
      cell.category_given_tr = ""
      cell.separator = ""
      cell.pretty_separator = ""
      cell.conflicted = false
      cell.updated = false
      cell.pvalue = cell.lvalue = cell.rvalue = nil
      cell.value = value
      cell.value = "" if cell.value == nil
      cell.pretty_value = cell.value
      vrow = "" if vrow == nil
      vcol = "" if vcol == nil
      removed_column = false
      cell.category = "move" if vrow == ":"
      cell.category = "index" if vrow == "" && offset == 1 && y == 0
      if (vcol.index("+++",nil || 0) || -1) >= 0 
        cell.category_given_tr = cell.category = "add"
      elsif (vcol.index("---",nil || 0) || -1) >= 0 
        cell.category_given_tr = cell.category = "remove"
        removed_column = true
      end
      if vrow == "!" 
        cell.category = "spec"
      elsif vrow == "@@" 
        cell.category = "header"
      elsif vrow == "..." 
        cell.category = "gap"
      elsif vrow == "+++" 
        cell.category = "add" if !removed_column
      elsif vrow == "---" 
        cell.category = "remove"
      elsif (vrow.index("->",nil || 0) || -1) >= 0 
        if !removed_column 
          tokens = vrow.split("!")
          full = vrow
          part = tokens[1]
          part = full if part == nil
          if nested || (cell.value.index(part,nil || 0) || -1) >= 0 
            cat = "modify"
            div = part
            if part != full 
              if nested 
                cell.conflicted = view.hash_exists(raw,"theirs")
              else 
                cell.conflicted = (cell.value.index(full,nil || 0) || -1) >= 0
              end
              if cell.conflicted 
                div = full
                cat = "conflict"
              end
            end
            cell.updated = true
            cell.separator = div
            cell.pretty_separator = div
            if nested 
              if cell.conflicted 
                tokens = [view.hash_get(raw,"before"),view.hash_get(raw,"ours"),view.hash_get(raw,"theirs")]
              else 
                tokens = [view.hash_get(raw,"before"),view.hash_get(raw,"after")]
              end
            elsif cell.pretty_value == div 
              tokens = ["",""]
            else 
              tokens = cell.pretty_value.split(div)
            end
            pretty_tokens = tokens
            if tokens.length >= 2 
              pretty_tokens[0] = ::Coopy::DiffRender.mark_spaces(tokens[0],tokens[1])
              pretty_tokens[1] = ::Coopy::DiffRender.mark_spaces(tokens[1],tokens[0])
            end
            if tokens.length >= 3 
              ref = pretty_tokens[0]
              pretty_tokens[0] = ::Coopy::DiffRender.mark_spaces(ref,tokens[2])
              pretty_tokens[2] = ::Coopy::DiffRender.mark_spaces(tokens[2],ref)
            end
            cell.pretty_separator = [8594].pack("U")
            cell.pretty_value = pretty_tokens.join(cell.pretty_separator)
            cell.category_given_tr = cell.category = cat
            offset1 = nil
            if cell.conflicted 
              offset1 = 1
            else 
              offset1 = 0
            end
            cell.lvalue = tokens[offset1]
            cell.rvalue = tokens[offset1 + 1]
            cell.pvalue = tokens[0] if cell.conflicted
          end
        end
      end
      cell.category_given_tr = cell.category = "index" if x == 0 && offset > 0
    end
    
    # protected - in ruby this doesn't play well with static/inline methods
    
    def DiffRender.mark_spaces(sl,sr)
      return sl if sl == sr
      return sl if sl == nil || sr == nil
      slc = sl.gsub(" ","")
      src = sr.gsub(" ","")
      return sl if slc != src
      slo = String.new("")
      il = 0
      ir = 0
      while(il < sl.length) 
        cl = sl[il]
        cr = ""
        cr = sr[ir] if ir < sr.length
        if cl == cr 
          slo += cl
          il+=1
          ir+=1
        elsif cr == " " 
          ir+=1
        else 
          slo += [9251].pack("U")
          il+=1
        end
      end
      return slo
    end
    
    public
    
    def DiffRender.render_cell(tab,view,x,y)
      cell = ::Coopy::CellInfo.new
      corner = view.to_s(tab.get_cell(0,0))
      off = nil
      if corner == "@:@" 
        off = 1
      else 
        off = 0
      end
      ::Coopy::DiffRender.examine_cell(x,y,view,tab.get_cell(x,y),view.to_s(tab.get_cell(x,off)),view.to_s(tab.get_cell(off,y)),corner,cell,off)
      return cell
    end
    
  haxe_me ["coopy", "DiffRender"]
  end

end
