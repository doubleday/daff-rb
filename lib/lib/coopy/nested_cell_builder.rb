#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class NestedCellBuilder 
    
    def initialize
    end
    
    protected
    
    attr_accessor :view
    
    public
    
    def need_separator 
      return false
    end
    
    def set_separator(separator)
    end
    
    def set_conflict_separator(separator)
    end
    
    def set_view(view)
      @view = view
    end
    
    def update(local,remote)
      h = @view.make_hash
      @view.hash_set(h,"before",local)
      @view.hash_set(h,"after",remote)
      return h
    end
    
    def conflict(parent,local,remote)
      h = @view.make_hash
      @view.hash_set(h,"before",parent)
      @view.hash_set(h,"ours",local)
      @view.hash_set(h,"theirs",remote)
      return h
    end
    
    def marker(label)
      return @view.to_datum(label)
    end
    
    protected
    
    def neg_to_null(x)
      return nil if x < 0
      return x
    end
    
    public
    
    def links(unit)
      h = @view.make_hash
      if unit.p >= -1 
        @view.hash_set(h,"before",self.neg_to_null(unit.p))
        @view.hash_set(h,"ours",self.neg_to_null(unit.l))
        @view.hash_set(h,"theirs",self.neg_to_null(unit.r))
        return h
      end
      @view.hash_set(h,"before",self.neg_to_null(unit.l))
      @view.hash_set(h,"after",self.neg_to_null(unit.r))
      return h
    end
    
  haxe_me ["coopy", "NestedCellBuilder"]
  end

end
