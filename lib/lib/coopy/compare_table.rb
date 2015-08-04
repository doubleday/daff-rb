#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class CompareTable 
    
    def initialize(comp)
      @comp = comp
    end
    
    protected
    
    attr_accessor :comp
    attr_accessor :indexes
    
    public
    
    def run 
      more = self.compare_core
      while(more && @comp.run_to_completion) 
        more = self.compare_core
      end
      return !more
    end
    
    def align 
      while(!@comp.completed) 
        self.run
      end
      alignment = ::Coopy::Alignment.new
      self.align_core(alignment)
      return alignment
    end
    
    def get_comparison_state 
      return @comp
    end
    
    protected
    
    def align_core(align)
      if @comp.p == nil 
        self.align_core2(align,@comp.a,@comp.b)
        return
      end
      align.reference = ::Coopy::Alignment.new
      self.align_core2(align,@comp.p,@comp.b)
      self.align_core2(align.reference,@comp.p,@comp.a)
      align.meta.reference = align.reference.meta
    end
    
    def align_core2(align,a,b)
      align.meta = ::Coopy::Alignment.new if align.meta == nil
      self.align_columns(align.meta,a,b)
      column_order = align.meta.to_order
      align.range(a.get_height,b.get_height)
      align.tables(a,b)
      align.set_rowlike(true)
      w = a.get_width
      ha = a.get_height
      hb = b.get_height
      av = a.get_cell_view
      ids = nil
      ignore = nil
      if @comp.compare_flags != nil 
        ids = @comp.compare_flags.ids
        ignore = @comp.compare_flags.get_ignored_columns
      end
      common_units = Array.new
      ra_header = align.get_source_header
      rb_header = align.get_source_header
      begin
        _g = 0
        _g1 = column_order.get_list
        while(_g < _g1.length) 
          unit = _g1[_g]
          _g+=1
          if unit.l >= 0 && unit.r >= 0 && unit.p != -1 
            if ignore != nil 
              if unit.l >= 0 && ra_header >= 0 && ra_header < a.get_height 
                name = av.to_s(a.get_cell(unit.l,ra_header))
                next if ignore.include?(name)
              end
              if unit.r >= 0 && rb_header >= 0 && rb_header < b.get_height 
                name1 = av.to_s(b.get_cell(unit.r,rb_header))
                next if ignore.include?(name1)
              end
            end
            common_units.push(unit)
          end
        end
      end
      if ids != nil 
        index = ::Coopy::IndexPair.new
        ids_as_map = {}
        begin
          _g2 = 0
          while(_g2 < ids.length) 
            id = ids[_g2]
            _g2+=1
            begin
              ids_as_map[id] = true
              true
            end
          end
        end
        begin
          _g3 = 0
          while(_g3 < common_units.length) 
            unit1 = common_units[_g3]
            _g3+=1
            na = av.to_s(a.get_cell(unit1.l,0))
            nb = av.to_s(b.get_cell(unit1.r,0))
            if ids_as_map.include?(na) || ids_as_map.include?(nb) 
              index.add_columns(unit1.l,unit1.r)
              align.add_index_columns(unit1)
            end
          end
        end
        index.index_tables(a,b)
        @indexes.push(index) if @indexes != nil
        begin
          _g4 = 0
          while(_g4 < ha) 
            j = _g4
            _g4+=1
            cross = index.query_local(j)
            spot_a = cross.spot_a
            spot_b = cross.spot_b
            next if spot_a != 1 || spot_b != 1
            align.link(j,cross.item_b.lst[0])
          end
        end
      else 
        n = 5
        columns = Array.new
        if common_units.length > n 
          columns_eval = Array.new
          begin
            _g11 = 0
            _g5 = common_units.length
            while(_g11 < _g5) 
              i = _g11
              _g11+=1
              ct = 0
              mem = {}
              mem2 = {}
              ca = common_units[i].l
              cb = common_units[i].r
              begin
                _g21 = 0
                while(_g21 < ha) 
                  j1 = _g21
                  _g21+=1
                  key = av.to_s(a.get_cell(ca,j1))
                  if !mem.include?(key) 
                    mem[key] = 1
                    ct+=1
                  end
                end
              end
              begin
                _g22 = 0
                while(_g22 < hb) 
                  j2 = _g22
                  _g22+=1
                  key1 = av.to_s(b.get_cell(cb,j2))
                  if !mem2.include?(key1) 
                    mem2[key1] = 1
                    ct+=1
                  end
                end
              end
              columns_eval.push([i,ct])
            end
          end
          sorter = lambda {|a1,b1|
            return 1 if a1[1] < b1[1]
            return -1 if a1[1] > b1[1]
            return 1 if a1[0] > b1[0]
            return -1 if a1[0] < b1[0]
            return 0
          }
          columns_eval.sort{|a,b| sorter.call(a,b)}
          columns = Lambda.array(Lambda.map(columns_eval,lambda {|v|
            return v[0]
          }))
          columns = columns.slice(0,n - 1)
        else 
          _g12 = 0
          _g6 = common_units.length
          while(_g12 < _g6) 
            i1 = _g12
            _g12+=1
            columns.push(i1)
          end
        end
        top = nil
        begin
          v1 = 2 ** columns.length
          top = v1.round
        end
        pending = {}
        begin
          _g7 = 0
          while(_g7 < ha) 
            j3 = _g7
            _g7+=1
            pending[j3] = j3
          end
        end
        pending_ct = ha
        added_columns = {}
        index_ct = 0
        index_top = nil
        begin
          _g8 = 0
          while(_g8 < top) 
            k = _g8
            _g8+=1
            next if k == 0
            break if pending_ct == 0
            active_columns = Array.new
            kk = k
            at = 0
            while(kk > 0) 
              active_columns.push(columns[at]) if kk.remainder(2) == 1
              kk >>= 1
              at+=1
            end
            index1 = ::Coopy::IndexPair.new
            begin
              _g23 = 0
              _g13 = active_columns.length
              while(_g23 < _g13) 
                k1 = _g23
                _g23+=1
                col = active_columns[k1]
                unit2 = common_units[col]
                index1.add_columns(unit2.l,unit2.r)
                if !added_columns.include?(col) 
                  align.add_index_columns(unit2)
                  added_columns[col] = true
                end
              end
            end
            index1.index_tables(a,b)
            index_top = index1 if k == top - 1
            h = a.get_height
            h = b.get_height if b.get_height > h
            h = 1 if h < 1
            wide_top_freq = index1.get_top_freq
            ratio = wide_top_freq
            ratio /= h + 20
            if ratio >= 0.1 
              next if index_ct > 0 || k < top - 1
            end
            index_ct+=1
            @indexes.push(index1) if @indexes != nil
            fixed = Array.new
            _it = ::Rb::RubyIterator.new(pending.keys)
            while(_it.has_next) do
              j4 = _it._next
              cross1 = index1.query_local(j4)
              spot_a1 = cross1.spot_a
              spot_b1 = cross1.spot_b
              next if spot_a1 != 1 || spot_b1 != 1
              fixed.push(j4)
              align.link(j4,cross1.item_b.lst[0])
            end
            begin
              _g24 = 0
              _g14 = fixed.length
              while(_g24 < _g14) 
                j5 = _g24
                _g24+=1
                pending.delete(fixed[j5])
                pending_ct-=1
              end
            end
          end
        end
        if index_top != nil 
          offset = 0
          scale = 1
          begin
            _g9 = 0
            while(_g9 < 2) 
              sgn = _g9
              _g9+=1
              if pending_ct > 0 
                xb = nil
                xb = hb - 1 if scale == -1 && hb > 0
                begin
                  _g15 = 0
                  while(_g15 < ha) 
                    xa0 = _g15
                    _g15+=1
                    xa = xa0 * scale + offset
                    xb2 = align.a2b(xa)
                    if xb2 != nil 
                      xb = xb2 + scale
                      break if xb >= hb || xb < 0
                      next
                    end
                    next if xb == nil
                    ka = index_top.local_key(xa)
                    kb = index_top.remote_key(xb)
                    next if ka != kb
                    align.link(xa,xb)
                    pending_ct-=1
                    xb += scale
                    break if xb >= hb || xb < 0
                    break if pending_ct == 0
                  end
                end
              end
              offset = ha - 1
              scale = -1
            end
          end
        end
      end
      align.link(0,0) if ha > 0 && hb > 0
    end
    
    def align_columns(align,a,b)
      align.range(a.get_width,b.get_width)
      align.tables(a,b)
      align.set_rowlike(false)
      slop = 5
      va = a.get_cell_view
      vb = b.get_cell_view
      ra_best = 0
      rb_best = 0
      ct_best = -1
      ma_best = nil
      mb_best = nil
      ra_header = 0
      rb_header = 0
      ra_uniques = 0
      rb_uniques = 0
      begin
        _g = 0
        while(_g < slop) 
          ra = _g
          _g+=1
          break if ra >= a.get_height
          begin
            _g1 = 0
            while(_g1 < slop) 
              rb1 = _g1
              _g1+=1
              break if rb1 >= b.get_height
              ma = {}
              mb = {}
              ct = 0
              uniques = 0
              begin
                _g3 = 0
                _g2 = a.get_width
                while(_g3 < _g2) 
                  ca = _g3
                  _g3+=1
                  key = va.to_s(a.get_cell(ca,ra))
                  if ma.include?(key) 
                    ma[key] = -1
                    uniques-=1
                  else 
                    ma[key] = ca
                    uniques+=1
                  end
                end
              end
              if uniques > ra_uniques 
                ra_header = ra
                ra_uniques = uniques
              end
              uniques = 0
              begin
                _g31 = 0
                _g21 = b.get_width
                while(_g31 < _g21) 
                  cb = _g31
                  _g31+=1
                  key1 = vb.to_s(b.get_cell(cb,rb1))
                  if mb.include?(key1) 
                    mb[key1] = -1
                    uniques-=1
                  else 
                    mb[key1] = cb
                    uniques+=1
                  end
                end
              end
              if uniques > rb_uniques 
                rb_header = rb1
                rb_uniques = uniques
              end
              _it = ::Rb::RubyIterator.new(ma.keys)
              while(_it.has_next) do
                key2 = _it._next
                i0 = ma[key2]
                i1 = mb[key2]
                if i1 != nil 
                  ct+=1 if i1 >= 0 && i0 >= 0
                end
              end
              if ct > ct_best 
                ct_best = ct
                ma_best = ma
                mb_best = mb
                ra_best = ra
                rb_best = rb1
              end
            end
          end
        end
      end
      if ma_best == nil 
        if a.get_height > 0 && b.get_height == 0 
          align.headers(0,-1)
        elsif a.get_height == 0 && b.get_height > 0 
          align.headers(-1,0)
        end
        return
      end
      _it2 = ::Rb::RubyIterator.new(ma_best.keys)
      while(_it2.has_next) do
        key3 = _it2._next
        i01 = ma_best[key3]
        i11 = mb_best[key3]
        align.link(i01,i11) if i11 != nil && i01 != nil
      end
      align.headers(ra_header,rb_header)
    end
    
    def test_has_same_columns 
      p = @comp.p
      a = @comp.a
      b = @comp.b
      eq = self.has_same_columns2(a,b)
      eq = self.has_same_columns2(p,a) if eq && p != nil
      @comp.has_same_columns = eq
      @comp.has_same_columns_known = true
      return true
    end
    
    def has_same_columns2(a,b)
      return false if a.get_width != b.get_width
      return true if a.get_height == 0 || b.get_height == 0
      av = a.get_cell_view
      begin
        _g1 = 0
        _g = a.get_width
        while(_g1 < _g) 
          i = _g1
          _g1+=1
          begin
            _g3 = i + 1
            _g2 = a.get_width
            while(_g3 < _g2) 
              j = _g3
              _g3+=1
              return false if av.equals(a.get_cell(i,0),a.get_cell(j,0))
            end
          end
          return false if !av.equals(a.get_cell(i,0),b.get_cell(i,0))
        end
      end
      return true
    end
    
    def test_is_equal 
      p = @comp.p
      a = @comp.a
      b = @comp.b
      eq = self.is_equal2(a,b)
      eq = self.is_equal2(p,a) if eq && p != nil
      @comp.is_equal = eq
      @comp.is_equal_known = true
      return true
    end
    
    def is_equal2(a,b)
      return false if a.get_width != b.get_width || a.get_height != b.get_height
      av = a.get_cell_view
      begin
        _g1 = 0
        _g = a.get_height
        while(_g1 < _g) 
          i = _g1
          _g1+=1
          begin
            _g3 = 0
            _g2 = a.get_width
            while(_g3 < _g2) 
              j = _g3
              _g3+=1
              return false if !av.equals(a.get_cell(j,i),b.get_cell(j,i))
            end
          end
        end
      end
      return true
    end
    
    def compare_core 
      return false if @comp.completed
      return self.test_is_equal if !@comp.is_equal_known
      return self.test_has_same_columns if !@comp.has_same_columns_known
      @comp.completed = true
      return false
    end
    
    public
    
    def store_indexes 
      @indexes = Array.new
    end
    
    def get_indexes 
      return @indexes
    end
    
  haxe_me ["coopy", "CompareTable"]
  end

end
