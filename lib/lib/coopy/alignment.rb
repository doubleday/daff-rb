#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class Alignment 
    
    def initialize
      @map_a2b = {}
      @map_b2a = {}
      @ha = @hb = 0
      @map_count = 0
      @reference = nil
      @meta = nil
      @order_cache_has_reference = false
      @ia = -1
      @ib = -1
    end
    
    protected
    
    attr_accessor :map_a2b
    attr_accessor :map_b2a
    attr_accessor :ha
    attr_accessor :hb
    attr_accessor :ta
    attr_accessor :tb
    attr_accessor :ia
    attr_accessor :ib
    attr_accessor :map_count
    attr_accessor :order_cache
    attr_accessor :order_cache_has_reference
    attr_accessor :index_columns
    
    public
    
    attr_accessor :reference
    attr_accessor :meta
    
    def range(ha,hb)
      @ha = ha
      @hb = hb
    end
    
    def tables(ta,tb)
      @ta = ta
      @tb = tb
    end
    
    def headers(ia,ib)
      @ia = ia
      @ib = ib
    end
    
    def set_rowlike(flag)
    end
    
    def link(a,b)
      @map_a2b[a] = b
      @map_b2a[b] = a
      @map_count+=1
    end
    
    def add_index_columns(unit)
      @index_columns = Array.new if @index_columns == nil
      @index_columns.push(unit)
    end
    
    def get_index_columns 
      return @index_columns
    end
    
    def a2b(a)
      return @map_a2b[a]
    end
    
    def b2a(b)
      return @map_b2a[b]
    end
    
    def count 
      return @map_count
    end
    
    def to_s 
      return "" + "not implemented yet"
    end
    
    def to_order 
      if @order_cache != nil 
        if @reference != nil 
          @order_cache = nil if !@order_cache_has_reference
        end
      end
      @order_cache = self.to_order3 if @order_cache == nil
      @order_cache_has_reference = true if @reference != nil
      return @order_cache
    end
    
    def add_to_order(l,r,p = -2)
      @order_cache = ::Coopy::Ordering.new if @order_cache == nil
      @order_cache.add(l,r,p)
      @order_cache_has_reference = p != -2
    end
    
    def get_source 
      return @ta
    end
    
    def get_target 
      return @tb
    end
    
    def get_source_header 
      return @ia
    end
    
    def get_target_header 
      return @ib
    end
    
    protected
    
    def to_order3 
      ref = @reference
      if ref == nil 
        ref = ::Coopy::Alignment.new
        ref.range(@ha,@ha)
        ref.tables(@ta,@ta)
        begin
          _g1 = 0
          _g = @ha
          while(_g1 < _g) 
            i = _g1
            _g1+=1
            ref.link(i,i)
          end
        end
      end
      order = ::Coopy::Ordering.new
      order.ignore_parent if @reference == nil
      xp = 0
      xl = 0
      xr = 0
      hp = @ha
      hl = ref.hb
      hr = @hb
      vp = {}
      vl = {}
      vr = {}
      begin
        _g2 = 0
        while(_g2 < hp) 
          i1 = _g2
          _g2+=1
          vp[i1] = i1
        end
      end
      begin
        _g3 = 0
        while(_g3 < hl) 
          i2 = _g3
          _g3+=1
          vl[i2] = i2
        end
      end
      begin
        _g4 = 0
        while(_g4 < hr) 
          i3 = _g4
          _g4+=1
          vr[i3] = i3
        end
      end
      ct_vp = hp
      ct_vl = hl
      ct_vr = hr
      prev = -1
      ct = 0
      max_ct = (hp + hl + hr) * 10
      while(ct_vp > 0 || ct_vl > 0 || ct_vr > 0) 
        ct+=1
        if ct > max_ct 
          puts "Ordering took too long, something went wrong"
          break
        end
        xp = 0 if xp >= hp
        xl = 0 if xl >= hl
        xr = 0 if xr >= hr
        if xp < hp && ct_vp > 0 
          if self.a2b(xp) == nil && ref.a2b(xp) == nil 
            if vp.include?(xp) 
              order.add(-1,-1,xp)
              prev = xp
              vp.delete(xp)
              ct_vp-=1
            end
            xp+=1
            next
          end
        end
        zl = nil
        zr = nil
        if xl < hl && ct_vl > 0 
          zl = ref.b2a(xl)
          if zl == nil 
            if vl.include?(xl) 
              order.add(xl,-1,-1)
              vl.delete(xl)
              ct_vl-=1
            end
            xl+=1
            next
          end
        end
        if xr < hr && ct_vr > 0 
          zr = self.b2a(xr)
          if zr == nil 
            if vr.include?(xr) 
              order.add(-1,xr,-1)
              vr.delete(xr)
              ct_vr-=1
            end
            xr+=1
            next
          end
        end
        if zl != nil 
          if self.a2b(zl) == nil 
            if vl.include?(xl) 
              order.add(xl,-1,zl)
              prev = zl
              vp.delete(zl)
              ct_vp-=1
              vl.delete(xl)
              ct_vl-=1
              xp = zl + 1
            end
            xl+=1
            next
          end
        end
        if zr != nil 
          if ref.a2b(zr) == nil 
            if vr.include?(xr) 
              order.add(-1,xr,zr)
              prev = zr
              vp.delete(zr)
              ct_vp-=1
              vr.delete(xr)
              ct_vr-=1
              xp = zr + 1
            end
            xr+=1
            next
          end
        end
        if zl != nil && zr != nil && self.a2b(zl) != nil && ref.a2b(zr) != nil 
          if zl == prev + 1 || zr != prev + 1 
            if vr.include?(xr) 
              order.add(ref.a2b(zr),xr,zr)
              prev = zr
              vp.delete(zr)
              ct_vp-=1
              begin
                key = ref.a2b(zr)
                vl.delete(key)
              end
              ct_vl-=1
              vr.delete(xr)
              ct_vr-=1
              xp = zr + 1
              xl = ref.a2b(zr) + 1
            end
            xr+=1
            next
          else 
            if vl.include?(xl) 
              order.add(xl,self.a2b(zl),zl)
              prev = zl
              vp.delete(zl)
              ct_vp-=1
              vl.delete(xl)
              ct_vl-=1
              begin
                key1 = self.a2b(zl)
                vr.delete(key1)
              end
              ct_vr-=1
              xp = zl + 1
              xr = self.a2b(zl) + 1
            end
            xl+=1
            next
          end
        end
        xp+=1
        xl+=1
        xr+=1
      end
      return order
    end
    
  haxe_me ["coopy", "Alignment"]
  end

end
