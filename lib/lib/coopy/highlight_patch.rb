#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class HighlightPatch 
    
    def initialize(source,patch)
      @source = source
      @patch = patch
      @view = patch.get_cell_view
      @source_view = source.get_cell_view
    end
    
    protected
    
    attr_accessor :source
    attr_accessor :patch
    attr_accessor :view
    attr_accessor :source_view
    attr_accessor :csv
    attr_accessor :header
    attr_accessor :header_pre
    attr_accessor :header_post
    attr_accessor :header_rename
    attr_accessor :header_move
    attr_accessor :modifier
    attr_accessor :current_row
    attr_accessor :payload_col
    attr_accessor :payload_top
    attr_accessor :mods
    attr_accessor :cmods
    attr_accessor :row_info
    attr_accessor :cell_info
    attr_accessor :rc_offset
    attr_accessor :indexes
    attr_accessor :source_in_patch_col
    attr_accessor :patch_in_source_col
    attr_accessor :patch_in_source_row
    attr_accessor :last_source_row
    attr_accessor :actions
    attr_accessor :row_permutation
    attr_accessor :row_permutation_rev
    attr_accessor :col_permutation
    attr_accessor :col_permutation_rev
    attr_accessor :have_dropped_columns
    
    def reset 
      @header = {}
      @header_pre = {}
      @header_post = {}
      @header_rename = {}
      @header_move = nil
      @modifier = {}
      @mods = Array.new
      @cmods = Array.new
      @csv = ::Coopy::Csv.new
      @rc_offset = 0
      @current_row = -1
      @row_info = ::Coopy::CellInfo.new
      @cell_info = ::Coopy::CellInfo.new
      @source_in_patch_col = @patch_in_source_col = nil
      @patch_in_source_row = {}
      @indexes = nil
      @last_source_row = -1
      @actions = Array.new
      @row_permutation = nil
      @row_permutation_rev = nil
      @col_permutation = nil
      @col_permutation_rev = nil
      @have_dropped_columns = false
    end
    
    public
    
    def apply 
      self.reset
      return true if @patch.get_width < 2
      return true if @patch.get_height < 1
      @payload_col = 1 + @rc_offset
      @payload_top = @patch.get_width
      corner = @patch.get_cell_view.to_s(@patch.get_cell(0,0))
      if corner == "@:@" 
        @rc_offset = 1
      else 
        @rc_offset = 0
      end
      begin
        _g1 = 0
        _g = @patch.get_height
        while(_g1 < _g) 
          r = _g1
          _g1+=1
          str = @view.to_s(@patch.get_cell(@rc_offset,r))
          @actions.push(((str != nil) ? str : ""))
        end
      end
      begin
        _g11 = 0
        _g2 = @patch.get_height
        while(_g11 < _g2) 
          r1 = _g11
          _g11+=1
          self.apply_row(r1)
        end
      end
      self.finish_rows
      self.finish_columns
      return true
    end
    
    protected
    
    def need_source_columns 
      return if @source_in_patch_col != nil
      @source_in_patch_col = {}
      @patch_in_source_col = {}
      av = @source.get_cell_view
      begin
        _g1 = 0
        _g = @source.get_width
        while(_g1 < _g) 
          i = _g1
          _g1+=1
          name = av.to_s(@source.get_cell(i,0))
          at = @header_pre[name]
          next if at == nil
          @source_in_patch_col[i] = at
          @patch_in_source_col[at] = i
        end
      end
    end
    
    def need_source_index 
      return if @indexes != nil
      state = ::Coopy::TableComparisonState.new
      state.a = @source
      state.b = @source
      comp = ::Coopy::CompareTable.new(state)
      comp.store_indexes
      comp.run
      comp.align
      @indexes = comp.get_indexes
      self.need_source_columns
    end
    
    def apply_row(r)
      @current_row = r
      code = @actions[r]
      if r == 0 && @rc_offset > 0 
      elsif code == "@@" 
        self.apply_header
        self.apply_action("@@")
      elsif code == "!" 
        self.apply_meta
      elsif code == "+++" 
        self.apply_action(code)
      elsif code == "---" 
        self.apply_action(code)
      elsif code == "+" || code == ":" 
        self.apply_action(code)
      elsif (code.index("->",nil || 0) || -1) >= 0 
        self.apply_action("->")
      else 
        @last_source_row = -1
      end
    end
    
    def get_datum(c)
      return @patch.get_cell(c,@current_row)
    end
    
    def get_string(c)
      return @view.to_s(self.get_datum(c))
    end
    
    def apply_meta 
      _g1 = @payload_col
      _g = @payload_top
      while(_g1 < _g) 
        i = _g1
        _g1+=1
        name = self.get_string(i)
        next if name == ""
        @modifier[i] = name
      end
    end
    
    def apply_header 
      begin
        _g1 = @payload_col
        _g = @payload_top
        while(_g1 < _g) 
          i = _g1
          _g1+=1
          name = self.get_string(i)
          if name == "..." 
            @modifier[i] = "..."
            @have_dropped_columns = true
            next
          end
          mod = @modifier[i]
          move = false
          if mod != nil 
            if (mod[0].ord rescue nil) == 58 
              move = true
              mod = mod[1,mod.length]
            end
          end
          @header[i] = name
          if mod != nil 
            if (mod[0].ord rescue nil) == 40 
              prev_name = mod[1,mod.length - 2]
              @header_pre[prev_name] = i
              @header_post[name] = i
              @header_rename[prev_name] = name
              next
            end
          end
          @header_pre[name] = i if mod != "+++"
          @header_post[name] = i if mod != "---"
          if move 
            @header_move = {} if @header_move == nil
            @header_move[name] = 1
          end
        end
      end
      self.apply_action("+++") if @source.get_height == 0
    end
    
    def look_up(del = 0)
      at = @patch_in_source_row[@current_row + del]
      return at if at != nil
      result = -1
      @current_row += del
      if @current_row >= 0 && @current_row < @patch.get_height 
        _g = 0
        _g1 = @indexes
        while(_g < _g1.length) 
          idx = _g1[_g]
          _g+=1
          match = idx.query_by_content(self)
          next if match.spot_a != 1
          result = match.item_a.lst[0]
          break
        end
      end
      begin
        @patch_in_source_row[@current_row] = result
        result
      end
      @current_row -= del
      return result
    end
    
    def apply_action(code)
      mod = ::Coopy::HighlightPatchUnit.new
      mod.code = code
      mod.add = code == "+++"
      mod.rem = code == "---"
      mod.update = code == "->"
      self.need_source_index
      @last_source_row = self.look_up(-1) if @last_source_row == -1
      mod.source_prev_row = @last_source_row
      next_act = @actions[@current_row + 1]
      mod.source_next_row = self.look_up(1) if next_act != "+++" && next_act != "..."
      if mod.add 
        mod.source_prev_row = self.look_up(-1) if @actions[@current_row - 1] != "+++"
        mod.source_row = mod.source_prev_row
        mod.source_row_offset = 1 if mod.source_row != -1
      else 
        mod.source_row = @last_source_row = self.look_up
      end
      @last_source_row = mod.source_next_row if @actions[@current_row + 1] == ""
      mod.patch_row = @current_row
      mod.source_row = 0 if code == "@@"
      @mods.push(mod)
    end
    
    def check_act 
      act = self.get_string(@rc_offset)
      ::Coopy::DiffRender.examine_cell(0,0,@view,act,"",act,"",@row_info) if @row_info.value != act
    end
    
    def get_pre_string(txt)
      self.check_act
      return txt if !@row_info.updated
      ::Coopy::DiffRender.examine_cell(0,0,@view,txt,"",@row_info.value,"",@cell_info)
      return txt if !@cell_info.updated
      return @cell_info.lvalue
    end
    
    public
    
    def get_row_string(c)
      at = @source_in_patch_col[c]
      return "NOT_FOUND" if at == nil
      return self.get_pre_string(self.get_string(at))
    end
    
    protected
    
    def sort_mods(a,b)
      return 1 if b.code == "@@" && a.code != "@@"
      return -1 if a.code == "@@" && b.code != "@@"
      return 1 if a.source_row == -1 && !a.add && b.source_row != -1
      return -1 if a.source_row != -1 && !b.add && b.source_row == -1
      return 1 if a.source_row + a.source_row_offset > b.source_row + b.source_row_offset
      return -1 if a.source_row + a.source_row_offset < b.source_row + b.source_row_offset
      return 1 if a.patch_row > b.patch_row
      return -1 if a.patch_row < b.patch_row
      return 0
    end
    
    def process_mods(rmods,fate,len)
      rmods.sort{|a,b| self.sort_mods(a,b)}
      offset = 0
      last = -1
      target = 0
      if rmods.length > 0 
        last = 0 if rmods[0].source_prev_row == -1
      end
      begin
        _g = 0
        while(_g < rmods.length) 
          mod = rmods[_g]
          _g+=1
          if last != -1 
            _g2 = last
            _g1 = mod.source_row + mod.source_row_offset
            while(_g2 < _g1) 
              i = _g2
              _g2+=1
              fate.push(i + offset)
              target+=1
              last+=1
            end
          end
          if mod.rem 
            fate.push(-1)
            offset-=1
          elsif mod.add 
            mod.dest_row = target
            target+=1
            offset+=1
          else 
            mod.dest_row = target
          end
          if mod.source_row >= 0 
            last = mod.source_row + mod.source_row_offset
            last+=1 if mod.rem
          else 
            last = -1
          end
        end
      end
      if last != -1 
        _g3 = last
        while(_g3 < len) 
          i1 = _g3
          _g3+=1
          fate.push(i1 + offset)
          target+=1
          last+=1
        end
      end
      return len + offset
    end
    
    def compute_ordering(mods,permutation,permutation_rev,dim)
      to_unit = {}
      from_unit = {}
      meta_from_unit = {}
      ct = 0
      begin
        _g = 0
        while(_g < mods.length) 
          mod = mods[_g]
          _g+=1
          next if mod.add || mod.rem
          next if mod.source_row < 0
          if mod.source_prev_row >= 0 
            begin
              v = mod.source_row
              to_unit[mod.source_prev_row] = v
              v
            end
            begin
              v1 = mod.source_prev_row
              from_unit[mod.source_row] = v1
              v1
            end
            ct+=1 if mod.source_prev_row + 1 != mod.source_row
          end
          if mod.source_next_row >= 0 
            begin
              v2 = mod.source_next_row
              to_unit[mod.source_row] = v2
              v2
            end
            begin
              v3 = mod.source_row
              from_unit[mod.source_next_row] = v3
              v3
            end
            ct+=1 if mod.source_row + 1 != mod.source_next_row
          end
        end
      end
      if ct > 0 
        cursor = nil
        logical = nil
        starts = []
        begin
          _g1 = 0
          while(_g1 < dim) 
            i = _g1
            _g1+=1
            u = from_unit[i]
            if u != nil 
              begin
                meta_from_unit[u] = i
                i
              end
            else 
              starts.push(i)
            end
          end
        end
        used = {}
        len = 0
        begin
          _g2 = 0
          while(_g2 < dim) 
            i1 = _g2
            _g2+=1
            if meta_from_unit.include?(logical) 
              cursor = meta_from_unit[logical]
            else 
              cursor = nil
            end
            if cursor == nil 
              v4 = starts.shift
              cursor = v4
              logical = v4
            end
            cursor = 0 if cursor == nil
            while(used.include?(cursor)) 
              cursor = ((cursor + 1).remainder(dim) rescue Float::NAN)
            end
            logical = cursor
            permutation_rev.push(cursor)
            begin
              used[cursor] = 1
              1
            end
          end
        end
        begin
          _g11 = 0
          _g3 = permutation_rev.length
          while(_g11 < _g3) 
            i2 = _g11
            _g11+=1
            permutation[i2] = -1
          end
        end
        begin
          _g12 = 0
          _g4 = permutation.length
          while(_g12 < _g4) 
            i3 = _g12
            _g12+=1
            permutation[permutation_rev[i3]] = i3
          end
        end
      end
    end
    
    def permute_rows 
      @row_permutation = Array.new
      @row_permutation_rev = Array.new
      self.compute_ordering(@mods,@row_permutation,@row_permutation_rev,@source.get_height)
    end
    
    def finish_rows 
      fate = Array.new
      self.permute_rows
      if @row_permutation.length > 0 
        _g = 0
        _g1 = @mods
        while(_g < _g1.length) 
          mod = _g1[_g]
          _g+=1
          mod.source_row = @row_permutation[mod.source_row] if mod.source_row >= 0
        end
      end
      @source.insert_or_delete_rows(@row_permutation,@row_permutation.length) if @row_permutation.length > 0
      len = self.process_mods(@mods,fate,@source.get_height)
      @source.insert_or_delete_rows(fate,len)
      begin
        _g2 = 0
        _g11 = @mods
        while(_g2 < _g11.length) 
          mod1 = _g11[_g2]
          _g2+=1
          if !mod1.rem 
            if mod1.add 
              _it = ::Rb::RubyIterator.new(@header_post.values)
              while(_it.has_next) do
                c = _it._next
                offset = @patch_in_source_col[c]
                @source.set_cell(offset,mod1.dest_row,@patch.get_cell(c,mod1.patch_row)) if offset != nil && offset >= 0
              end
            elsif mod1.update 
              @current_row = mod1.patch_row
              self.check_act
              next if !@row_info.updated
              _it2 = ::Rb::RubyIterator.new(@header_pre.values)
              while(_it2.has_next) do
                c1 = _it2._next
                txt = @view.to_s(@patch.get_cell(c1,mod1.patch_row))
                ::Coopy::DiffRender.examine_cell(0,0,@view,txt,"",@row_info.value,"",@cell_info)
                next if !@cell_info.updated
                next if @cell_info.conflicted
                d = @view.to_datum(@csv.parse_cell(@cell_info.rvalue))
                @source.set_cell(@patch_in_source_col[c1],mod1.dest_row,d)
              end
            end
          end
        end
      end
    end
    
    def permute_columns 
      return if @header_move == nil
      @col_permutation = Array.new
      @col_permutation_rev = Array.new
      self.compute_ordering(@cmods,@col_permutation,@col_permutation_rev,@source.get_width)
      return if @col_permutation.length == 0
    end
    
    def finish_columns 
      self.need_source_columns
      begin
        _g1 = @payload_col
        _g = @payload_top
        while(_g1 < _g) 
          i = _g1
          _g1+=1
          act = @modifier[i]
          hdr = @header[i]
          act = "" if act == nil
          if act == "---" 
            at = @patch_in_source_col[i]
            mod = ::Coopy::HighlightPatchUnit.new
            mod.code = act
            mod.rem = true
            mod.source_row = at
            mod.patch_row = i
            @cmods.push(mod)
          elsif act == "+++" 
            mod1 = ::Coopy::HighlightPatchUnit.new
            mod1.code = act
            mod1.add = true
            prev = -1
            cont = false
            mod1.source_row = -1
            mod1.source_row = @cmods[@cmods.length - 1].source_row if @cmods.length > 0
            mod1.source_row_offset = 1 if mod1.source_row != -1
            mod1.patch_row = i
            @cmods.push(mod1)
          elsif act != "..." 
            mod2 = ::Coopy::HighlightPatchUnit.new
            mod2.code = act
            mod2.patch_row = i
            mod2.source_row = @patch_in_source_col[i]
            @cmods.push(mod2)
          end
        end
      end
      at1 = -1
      rat = -1
      begin
        _g11 = 0
        _g2 = @cmods.length - 1
        while(_g11 < _g2) 
          i1 = _g11
          _g11+=1
          icode = @cmods[i1].code
          at1 = @cmods[i1].source_row if icode != "+++" && icode != "---"
          @cmods[i1 + 1].source_prev_row = at1
          j = @cmods.length - 1 - i1
          jcode = @cmods[j].code
          rat = @cmods[j].source_row if jcode != "+++" && jcode != "---"
          @cmods[j - 1].source_next_row = rat
        end
      end
      fate = Array.new
      self.permute_columns
      if @header_move != nil 
        if @col_permutation.length > 0 
          begin
            _g3 = 0
            _g12 = @cmods
            while(_g3 < _g12.length) 
              mod3 = _g12[_g3]
              _g3+=1
              mod3.source_row = @col_permutation[mod3.source_row] if mod3.source_row >= 0
            end
          end
          @source.insert_or_delete_columns(@col_permutation,@col_permutation.length)
        end
      end
      len = self.process_mods(@cmods,fate,@source.get_width)
      @source.insert_or_delete_columns(fate,len)
      begin
        _g4 = 0
        _g13 = @cmods
        while(_g4 < _g13.length) 
          cmod = _g13[_g4]
          _g4+=1
          if !cmod.rem 
            if cmod.add 
              begin
                _g21 = 0
                _g31 = @mods
                while(_g21 < _g31.length) 
                  mod4 = _g31[_g21]
                  _g21+=1
                  if mod4.patch_row != -1 && mod4.dest_row != -1 
                    d = @patch.get_cell(cmod.patch_row,mod4.patch_row)
                    @source.set_cell(cmod.dest_row,mod4.dest_row,d)
                  end
                end
              end
              hdr1 = @header[cmod.patch_row]
              @source.set_cell(cmod.dest_row,0,@view.to_datum(hdr1))
            end
          end
        end
      end
      begin
        _g14 = 0
        _g5 = @source.get_width
        while(_g14 < _g5) 
          i2 = _g14
          _g14+=1
          name = @view.to_s(@source.get_cell(i2,0))
          next_name = @header_rename[name]
          next if next_name == nil
          @source.set_cell(i2,0,@view.to_datum(next_name))
        end
      end
    end
    
  haxe_me ["coopy", "HighlightPatch"]
  end

end
