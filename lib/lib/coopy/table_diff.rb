#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class TableDiff 
    
    def initialize(align,flags)
      @align = align
      @flags = flags
      @builder = nil
    end
    
    protected
    
    attr_accessor :align
    attr_accessor :flags
    attr_accessor :builder
    
    public
    
    def set_cell_builder(builder)
      @builder = builder
    end
    
    protected
    
    def get_separator(t,t2,root)
      sep = root
      w = t.get_width
      h = t.get_height
      view = t.get_cell_view
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
              txt = view.to_s(t.get_cell(x,y))
              next if txt == nil
              while((txt.index(sep,nil || 0) || -1) >= 0) 
                sep = "-" + _hx_str(sep)
              end
            end
          end
        end
      end
      if t2 != nil 
        w = t2.get_width
        h = t2.get_height
        begin
          _g2 = 0
          while(_g2 < h) 
            y1 = _g2
            _g2+=1
            begin
              _g11 = 0
              while(_g11 < w) 
                x1 = _g11
                _g11+=1
                txt1 = view.to_s(t2.get_cell(x1,y1))
                next if txt1 == nil
                while((txt1.index(sep,nil || 0) || -1) >= 0) 
                  sep = "-" + _hx_str(sep)
                end
              end
            end
          end
        end
      end
      return sep
    end
    
    def quote_for_diff(v,d)
      _nil = "NULL"
      return _nil if v.equals(d,nil)
      str = v.to_s(d)
      score = 0
      begin
        _g1 = 0
        _g = str.length
        while(_g1 < _g) 
          i = _g1
          _g1+=1
          break if (str[score].ord rescue nil) != 95
          score+=1
        end
      end
      str = "_" + _hx_str(str) if str[score..-1] == _nil
      return str
    end
    
    def is_reordered(m,ct)
      reordered = false
      l = -1
      r = -1
      begin
        _g = 0
        while(_g < ct) 
          i = _g
          _g+=1
          unit = m[i]
          next if unit == nil
          if unit.l >= 0 
            if unit.l < l 
              reordered = true
              break
            end
            l = unit.l
          end
          if unit.r >= 0 
            if unit.r < r 
              reordered = true
              break
            end
            r = unit.r
          end
        end
      end
      return reordered
    end
    
    def spread_context(units,del,active)
      if del > 0 && active != nil 
        mark = -del - 1
        skips = 0
        begin
          _g1 = 0
          _g = units.length
          while(_g1 < _g) 
            i = _g1
            _g1+=1
            if active[i] == -3 
              skips+=1
              next
            end
            if active[i] == 0 || active[i] == 3 
              if i - mark <= del + skips 
                active[i] = 2
              elsif i - mark == del + 1 + skips 
                active[i] = 3
              end
            elsif active[i] == 1 
              mark = i
              skips = 0
            end
          end
        end
        mark = units.length + del + 1
        skips = 0
        begin
          _g11 = 0
          _g2 = units.length
          while(_g11 < _g2) 
            j = _g11
            _g11+=1
            i1 = units.length - 1 - j
            if active[i1] == -3 
              skips+=1
              next
            end
            if active[i1] == 0 || active[i1] == 3 
              if mark - i1 <= del + skips 
                active[i1] = 2
              elsif mark - i1 == del + 1 + skips 
                active[i1] = 3
              end
            elsif active[i1] == 1 
              mark = i1
              skips = 0
            end
          end
        end
      end
    end
    
    def set_ignore(ignore,idx_ignore,tab,r_header)
      v = tab.get_cell_view
      if tab.get_height >= r_header 
        _g1 = 0
        _g = tab.get_width
        while(_g1 < _g) 
          i = _g1
          _g1+=1
          name = v.to_s(tab.get_cell(i,r_header))
          next if !ignore.include?(name)
          idx_ignore[i] = true
        end
      end
    end
    
    def count_active(active)
      ct = 0
      showed_dummy = false
      begin
        _g1 = 0
        _g = active.length
        while(_g1 < _g) 
          i = _g1
          _g1+=1
          publish = active[i] > 0
          dummy = active[i] == 3
          next if dummy && showed_dummy
          next if !publish
          showed_dummy = dummy
          ct+=1
        end
      end
      return ct
    end
    
    public
    
    def hilite(output)
      return false if !output.is_resizable
      if @builder == nil 
        if @flags.allow_nested_cells 
          @builder = ::Coopy::NestedCellBuilder.new
        else 
          @builder = ::Coopy::FlatCellBuilder.new
        end
      end
      output.resize(0,0)
      output.clear
      row_map = {}
      col_map = {}
      order = @align.to_order
      units = order.get_list
      has_parent = @align.reference != nil
      a = nil
      b = nil
      p = nil
      rp_header = 0
      ra_header = 0
      rb_header = 0
      is_index_p = {}
      is_index_a = {}
      is_index_b = {}
      if has_parent 
        p = @align.get_source
        a = @align.reference.get_target
        b = @align.get_target
        rp_header = @align.reference.meta.get_source_header
        ra_header = @align.reference.meta.get_target_header
        rb_header = @align.meta.get_target_header
        if @align.get_index_columns != nil 
          _g = 0
          _g1 = @align.get_index_columns
          while(_g < _g1.length) 
            p2b = _g1[_g]
            _g+=1
            is_index_p[p2b.l] = true if p2b.l >= 0
            is_index_b[p2b.r] = true if p2b.r >= 0
          end
        end
        if @align.reference.get_index_columns != nil 
          _g2 = 0
          _g11 = @align.reference.get_index_columns
          while(_g2 < _g11.length) 
            p2a = _g11[_g2]
            _g2+=1
            is_index_p[p2a.l] = true if p2a.l >= 0
            is_index_a[p2a.r] = true if p2a.r >= 0
          end
        end
      else 
        a = @align.get_source
        b = @align.get_target
        p = a
        ra_header = @align.meta.get_source_header
        rp_header = ra_header
        rb_header = @align.meta.get_target_header
        if @align.get_index_columns != nil 
          _g3 = 0
          _g12 = @align.get_index_columns
          while(_g3 < _g12.length) 
            a2b = _g12[_g3]
            _g3+=1
            is_index_a[a2b.l] = true if a2b.l >= 0
            is_index_b[a2b.r] = true if a2b.r >= 0
          end
        end
      end
      column_order = @align.meta.to_order
      column_units = column_order.get_list
      p_ignore = {}
      a_ignore = {}
      b_ignore = {}
      ignore = @flags.get_ignored_columns
      if ignore != nil 
        self.set_ignore(ignore,p_ignore,p,rp_header)
        self.set_ignore(ignore,a_ignore,a,ra_header)
        self.set_ignore(ignore,b_ignore,b,rb_header)
        ncolumn_units = Array.new
        begin
          _g13 = 0
          _g4 = column_units.length
          while(_g13 < _g4) 
            j = _g13
            _g13+=1
            cunit = column_units[j]
            next if p_ignore.include?(cunit.p) || a_ignore.include?(cunit.l) || b_ignore.include?(cunit.r)
            ncolumn_units.push(cunit)
          end
        end
        column_units = ncolumn_units
      end
      show_rc_numbers = false
      row_moves = nil
      col_moves = nil
      if @flags.ordered 
        row_moves = {}
        moves = ::Coopy::Mover.move_units(units)
        begin
          _g14 = 0
          _g5 = moves.length
          while(_g14 < _g5) 
            i = _g14
            _g14+=1
            begin
              row_moves[moves[i]] = i
              i
            end
          end
        end
        col_moves = {}
        moves = ::Coopy::Mover.move_units(column_units)
        begin
          _g15 = 0
          _g6 = moves.length
          while(_g15 < _g6) 
            i1 = _g15
            _g15+=1
            begin
              col_moves[moves[i1]] = i1
              i1
            end
          end
        end
      end
      active = Array.new
      active_column = nil
      if !@flags.show_unchanged 
        _g16 = 0
        _g7 = units.length
        while(_g16 < _g7) 
          i2 = _g16
          _g16+=1
          active[units.length - 1 - i2] = 0
        end
      end
      allow_insert = @flags.allow_insert
      allow_delete = @flags.allow_delete
      allow_update = @flags.allow_update
      if !@flags.show_unchanged_columns 
        active_column = Array.new
        begin
          _g17 = 0
          _g8 = column_units.length
          while(_g17 < _g8) 
            i3 = _g17
            _g17+=1
            v = 0
            unit = column_units[i3]
            v = 1 if unit.l >= 0 && is_index_a[unit.l]
            v = 1 if unit.r >= 0 && is_index_b[unit.r]
            v = 1 if unit.p >= 0 && is_index_p[unit.p]
            active_column[i3] = v
          end
        end
      end
      v1 = a.get_cell_view
      @builder.set_view(v1)
      outer_reps_needed = nil
      if @flags.show_unchanged && @flags.show_unchanged_columns 
        outer_reps_needed = 1
      else 
        outer_reps_needed = 2
      end
      sep = ""
      conflict_sep = ""
      schema = Array.new
      have_schema = false
      begin
        _g18 = 0
        _g9 = column_units.length
        while(_g18 < _g9) 
          j1 = _g18
          _g18+=1
          cunit1 = column_units[j1]
          reordered = false
          if @flags.ordered 
            reordered = true if col_moves.include?(j1)
            show_rc_numbers = true if reordered
          end
          act = ""
          if cunit1.r >= 0 && cunit1.lp == -1 
            have_schema = true
            act = "+++"
            if active_column != nil 
              active_column[j1] = 1 if allow_update
            end
          end
          if cunit1.r < 0 && cunit1.lp >= 0 
            have_schema = true
            act = "---"
            if active_column != nil 
              active_column[j1] = 1 if allow_update
            end
          end
          if cunit1.r >= 0 && cunit1.lp >= 0 
            if p.get_height >= rp_header && b.get_height >= rb_header 
              pp = p.get_cell(cunit1.lp,rp_header)
              bb = b.get_cell(cunit1.r,rb_header)
              if !v1.equals(pp,bb) 
                have_schema = true
                act = "("
                act += v1.to_s(pp)
                act += ")"
                active_column[j1] = 1 if active_column != nil
              end
            end
          end
          if reordered 
            act = ":" + _hx_str(act)
            have_schema = true
            active_column = nil if active_column != nil
          end
          schema.push(act)
        end
      end
      if have_schema 
        at = output.get_height
        output.resize(column_units.length + 1,at + 1)
        output.set_cell(0,at,@builder.marker("!"))
        begin
          _g19 = 0
          _g10 = column_units.length
          while(_g19 < _g10) 
            j2 = _g19
            _g19+=1
            output.set_cell(j2 + 1,at,v1.to_datum(schema[j2]))
          end
        end
      end
      top_line_done = false
      if @flags.always_show_header 
        at1 = output.get_height
        output.resize(column_units.length + 1,at1 + 1)
        output.set_cell(0,at1,@builder.marker("@@"))
        begin
          _g110 = 0
          _g20 = column_units.length
          while(_g110 < _g20) 
            j3 = _g110
            _g110+=1
            cunit2 = column_units[j3]
            if cunit2.r >= 0 
              output.set_cell(j3 + 1,at1,b.get_cell(cunit2.r,rb_header)) if b.get_height != 0
            elsif cunit2.lp >= 0 
              output.set_cell(j3 + 1,at1,p.get_cell(cunit2.lp,rp_header)) if p.get_height != 0
            end
            col_map[j3 + 1] = cunit2
          end
        end
        top_line_done = true
      end
      output_height = output.get_height
      output_height_init = output.get_height
      begin
        _g21 = 0
        while(_g21 < outer_reps_needed) 
          out = _g21
          _g21+=1
          if out == 1 
            self.spread_context(units,@flags.unchanged_context,active)
            self.spread_context(column_units,@flags.unchanged_column_context,active_column)
            if active_column != nil 
              _g22 = 0
              _g111 = column_units.length
              while(_g22 < _g111) 
                i4 = _g22
                _g22+=1
                active_column[i4] = 0 if active_column[i4] == 3
              end
            end
            rows = self.count_active(active) + output_height_init
            rows-=1 if top_line_done
            output_height = output_height_init
            output.resize(column_units.length + 1,rows) if rows > output.get_height
          end
          showed_dummy = false
          l = -1
          r = -1
          begin
            _g23 = 0
            _g112 = units.length
            while(_g23 < _g112) 
              i5 = _g23
              _g23+=1
              unit1 = units[i5]
              reordered1 = false
              if @flags.ordered 
                reordered1 = true if row_moves.include?(i5)
                show_rc_numbers = true if reordered1
              end
              next if unit1.r < 0 && unit1.l < 0
              next if unit1.r == 0 && unit1.lp == 0 && top_line_done
              act1 = ""
              act1 = ":" if reordered1
              publish = @flags.show_unchanged
              dummy = false
              if out == 1 
                publish = active[i5] > 0
                dummy = active[i5] == 3
                next if dummy && showed_dummy
                next if !publish
              end
              showed_dummy = false if !dummy
              at2 = output_height
              if publish 
                output_height+=1
                output.resize(column_units.length + 1,output_height) if output.get_height < output_height
              end
              if dummy 
                begin
                  _g41 = 0
                  _g31 = column_units.length + 1
                  while(_g41 < _g31) 
                    j4 = _g41
                    _g41+=1
                    output.set_cell(j4,at2,v1.to_datum("..."))
                  end
                end
                showed_dummy = true
                next
              end
              have_addition = false
              skip = false
              if unit1.p < 0 && unit1.l < 0 && unit1.r >= 0 
                skip = true if !allow_insert
                act1 = "+++"
              end
              if (unit1.p >= 0 || !has_parent) && unit1.l >= 0 && unit1.r < 0 
                skip = true if !allow_delete
                act1 = "---"
              end
              if skip 
                if !publish 
                  active[i5] = -3 if active != nil
                end
                next
              end
              begin
                _g42 = 0
                _g32 = column_units.length
                while(_g42 < _g32) 
                  j5 = _g42
                  _g42+=1
                  cunit3 = column_units[j5]
                  pp1 = nil
                  ll = nil
                  rr = nil
                  dd = nil
                  dd_to = nil
                  have_dd_to = false
                  dd_to_alt = nil
                  have_dd_to_alt = false
                  have_pp = false
                  have_ll = false
                  have_rr = false
                  if cunit3.p >= 0 && unit1.p >= 0 
                    pp1 = p.get_cell(cunit3.p,unit1.p)
                    have_pp = true
                  end
                  if cunit3.l >= 0 && unit1.l >= 0 
                    ll = a.get_cell(cunit3.l,unit1.l)
                    have_ll = true
                  end
                  if cunit3.r >= 0 && unit1.r >= 0 
                    rr = b.get_cell(cunit3.r,unit1.r)
                    have_rr = true
                    if (((have_pp) ? cunit3.p : cunit3.l)) < 0 
                      if rr != nil 
                        if v1.to_s(rr) != "" 
                          have_addition = true if @flags.allow_update
                        end
                      end
                    end
                  end
                  if have_pp 
                    if !have_rr 
                      dd = pp1
                    elsif v1.equals(pp1,rr) 
                      dd = pp1
                    else 
                      dd = pp1
                      dd_to = rr
                      have_dd_to = true
                      if !v1.equals(pp1,ll) 
                        if !v1.equals(pp1,rr) 
                          dd_to_alt = ll
                          have_dd_to_alt = true
                        end
                      end
                    end
                  elsif have_ll 
                    if !have_rr 
                      dd = ll
                    elsif v1.equals(ll,rr) 
                      dd = ll
                    else 
                      dd = ll
                      dd_to = rr
                      have_dd_to = true
                    end
                  else 
                    dd = rr
                  end
                  cell = dd
                  if have_dd_to && allow_update 
                    active_column[j5] = 1 if active_column != nil
                    if sep == "" 
                      if @builder.need_separator 
                        sep = self.get_separator(a,b,"->")
                        @builder.set_separator(sep)
                      else 
                        sep = "->"
                      end
                    end
                    is_conflict = false
                    if have_dd_to_alt 
                      is_conflict = true if !v1.equals(dd_to,dd_to_alt)
                    end
                    if !is_conflict 
                      cell = @builder.update(dd,dd_to)
                      act1 = sep if sep.length > act1.length
                    else 
                      if conflict_sep == "" 
                        if @builder.need_separator 
                          conflict_sep = _hx_str(self.get_separator(p,a,"!")) + _hx_str(sep)
                          @builder.set_conflict_separator(conflict_sep)
                        else 
                          conflict_sep = "!->"
                        end
                      end
                      cell = @builder.conflict(dd,dd_to_alt,dd_to)
                      act1 = conflict_sep
                    end
                  end
                  act1 = "+" if act1 == "" && have_addition
                  if act1 == "+++" 
                    if have_rr 
                      active_column[j5] = 1 if active_column != nil
                    end
                  end
                  if publish 
                    output.set_cell(j5 + 1,at2,cell) if active_column == nil || active_column[j5] > 0
                  end
                end
              end
              if publish 
                output.set_cell(0,at2,@builder.marker(act1))
                row_map[at2] = unit1
              end
              if act1 != "" 
                if !publish 
                  active[i5] = 1 if active != nil
                end
              end
            end
          end
        end
      end
      if !show_rc_numbers 
        if @flags.always_show_order 
          show_rc_numbers = true
        elsif @flags.ordered 
          show_rc_numbers = self.is_reordered(row_map,output.get_height)
          show_rc_numbers = self.is_reordered(col_map,output.get_width) if !show_rc_numbers
        end
      end
      admin_w = 1
      if show_rc_numbers && !@flags.never_show_order 
        admin_w+=1
        target = Array.new
        begin
          _g113 = 0
          _g24 = output.get_width
          while(_g113 < _g24) 
            i6 = _g113
            _g113+=1
            target.push(i6 + 1)
          end
        end
        output.insert_or_delete_columns(target,output.get_width + 1)
        begin
          _g114 = 0
          _g25 = output.get_height
          while(_g114 < _g25) 
            i7 = _g114
            _g114+=1
            unit2 = row_map[i7]
            if unit2 == nil 
              output.set_cell(0,i7,"")
              next
            end
            output.set_cell(0,i7,@builder.links(unit2))
          end
        end
        target = Array.new
        begin
          _g115 = 0
          _g26 = output.get_height
          while(_g115 < _g26) 
            i8 = _g115
            _g115+=1
            target.push(i8 + 1)
          end
        end
        output.insert_or_delete_rows(target,output.get_height + 1)
        begin
          _g116 = 1
          _g27 = output.get_width
          while(_g116 < _g27) 
            i9 = _g116
            _g116+=1
            unit3 = col_map[i9 - 1]
            if unit3 == nil 
              output.set_cell(i9,0,"")
              next
            end
            output.set_cell(i9,0,@builder.links(unit3))
          end
        end
        output.set_cell(0,0,@builder.marker("@:@"))
      end
      if active_column != nil 
        all_active = true
        begin
          _g117 = 0
          _g28 = active_column.length
          while(_g117 < _g28) 
            i10 = _g117
            _g117+=1
            if active_column[i10] == 0 
              all_active = false
              break
            end
          end
        end
        if !all_active 
          fate = Array.new
          begin
            _g29 = 0
            while(_g29 < admin_w) 
              i11 = _g29
              _g29+=1
              fate.push(i11)
            end
          end
          at3 = admin_w
          ct = 0
          dots = Array.new
          begin
            _g118 = 0
            _g30 = active_column.length
            while(_g118 < _g30) 
              i12 = _g118
              _g118+=1
              off = active_column[i12] == 0
              if off 
                ct = ct + 1
              else 
                ct = 0
              end
              if off && ct > 1 
                fate.push(-1)
              else 
                dots.push(at3) if off
                fate.push(at3)
                at3+=1
              end
            end
          end
          output.insert_or_delete_columns(fate,at3)
          begin
            _g33 = 0
            while(_g33 < dots.length) 
              d = dots[_g33]
              _g33+=1
              begin
                _g210 = 0
                _g119 = output.get_height
                while(_g210 < _g119) 
                  j6 = _g210
                  _g210+=1
                  output.set_cell(d,j6,@builder.marker("..."))
                end
              end
            end
          end
        end
      end
      return true
    end
    
  haxe_me ["coopy", "TableDiff"]
  end

end
