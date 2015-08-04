#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class Merger 
    
    def initialize(parent,local,remote,flags)
      @parent = parent
      @local = local
      @remote = remote
      @flags = flags
    end
    
    # protected - in ruby this doesn't play well with static/inline methods
    
    attr_accessor :parent
    attr_accessor :local
    attr_accessor :remote
    attr_accessor :flags
    attr_accessor :order
    attr_accessor :units
    attr_accessor :column_order
    attr_accessor :column_units
    attr_accessor :row_mix_local
    attr_accessor :row_mix_remote
    attr_accessor :column_mix_local
    attr_accessor :column_mix_remote
    attr_accessor :conflicts
    
    def shuffle_dimension(dim_units,len,fate,cl,cr)
      at = 0
      begin
        _g = 0
        while(_g < dim_units.length) 
          cunit = dim_units[_g]
          _g+=1
          if cunit.p < 0 
            if cunit.l < 0 
              if cunit.r >= 0 
                begin
                  cr[cunit.r] = at
                  at
                end
                at+=1
              end
            else 
              begin
                cl[cunit.l] = at
                at
              end
              at+=1
            end
          elsif cunit.l >= 0 
            if cunit.r < 0 
            else 
              begin
                cl[cunit.l] = at
                at
              end
              at+=1
            end
          end
        end
      end
      begin
        _g1 = 0
        while(_g1 < len) 
          x = _g1
          _g1+=1
          idx = cl[x]
          if idx == nil 
            fate.push(-1)
          else 
            fate.push(idx)
          end
        end
      end
      return at
    end
    
    def shuffle_columns 
      @column_mix_local = {}
      @column_mix_remote = {}
      fate = Array.new
      wfate = self.shuffle_dimension(@column_units,@local.get_width,fate,@column_mix_local,@column_mix_remote)
      @local.insert_or_delete_columns(fate,wfate)
    end
    
    def shuffle_rows 
      @row_mix_local = {}
      @row_mix_remote = {}
      fate = Array.new
      hfate = self.shuffle_dimension(@units,@local.get_height,fate,@row_mix_local,@row_mix_remote)
      @local.insert_or_delete_rows(fate,hfate)
    end
    
    public
    
    def apply 
      @conflicts = 0
      ct = ::Coopy::Coopy.compare_tables3(@parent,@local,@remote)
      align = ct.align
      @order = align.to_order
      @units = @order.get_list
      @column_order = align.meta.to_order
      @column_units = @column_order.get_list
      allow_insert = @flags.allow_insert
      allow_delete = @flags.allow_delete
      allow_update = @flags.allow_update
      view = @parent.get_cell_view
      begin
        _g = 0
        _g1 = @units
        while(_g < _g1.length) 
          row = _g1[_g]
          _g+=1
          if row.l >= 0 && row.r >= 0 && row.p >= 0 
            _g2 = 0
            _g3 = @column_units
            while(_g2 < _g3.length) 
              col = _g3[_g2]
              _g2+=1
              if col.l >= 0 && col.r >= 0 && col.p >= 0 
                pcell = @parent.get_cell(col.p,row.p)
                rcell = @remote.get_cell(col.r,row.r)
                if !view.equals(pcell,rcell) 
                  lcell = @local.get_cell(col.l,row.l)
                  if view.equals(pcell,lcell) 
                    @local.set_cell(col.l,row.l,rcell)
                  else 
                    @local.set_cell(col.l,row.l,::Coopy::Merger.make_conflicted_cell(view,pcell,lcell,rcell))
                    @conflicts+=1
                  end
                end
              end
            end
          end
        end
      end
      self.shuffle_columns
      self.shuffle_rows
      _it = ::Rb::RubyIterator.new(@column_mix_remote.keys)
      while(_it.has_next) do
        x = _it._next
        x2 = @column_mix_remote[x]
        begin
          _g4 = 0
          _g11 = @units
          while(_g4 < _g11.length) 
            unit = _g11[_g4]
            _g4+=1
            if unit.l >= 0 && unit.r >= 0 
              @local.set_cell(x2,@row_mix_local[unit.l],@remote.get_cell(x,unit.r))
            elsif unit.p < 0 && unit.r >= 0 
              @local.set_cell(x2,@row_mix_remote[unit.r],@remote.get_cell(x,unit.r))
            end
          end
        end
      end
      _it2 = ::Rb::RubyIterator.new(@row_mix_remote.keys)
      while(_it2.has_next) do
        y = _it2._next
        y2 = @row_mix_remote[y]
        begin
          _g5 = 0
          _g12 = @column_units
          while(_g5 < _g12.length) 
            unit1 = _g12[_g5]
            _g5+=1
            @local.set_cell(@column_mix_local[unit1.l],y2,@remote.get_cell(unit1.r,y)) if unit1.l >= 0 && unit1.r >= 0
          end
        end
      end
      return @conflicts
    end
    
    # protected - in ruby this doesn't play well with static/inline methods
    
    def Merger.make_conflicted_cell(view,pcell,lcell,rcell)
      return view.to_datum("((( " + _hx_str(view.to_s(pcell)) + " ))) " + _hx_str(view.to_s(lcell)) + " /// " + _hx_str(view.to_s(rcell)))
    end
    
  haxe_me ["coopy", "Merger"]
  end

end
