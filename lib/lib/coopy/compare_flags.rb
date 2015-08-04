#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class CompareFlags 
    
    def initialize
      @ordered = true
      @show_unchanged = false
      @unchanged_context = 1
      @always_show_order = false
      @never_show_order = true
      @show_unchanged_columns = false
      @unchanged_column_context = 1
      @always_show_header = true
      @acts = nil
      @ids = nil
      @columns_to_ignore = nil
      @allow_nested_cells = false
    end
    
    attr_accessor :ordered
    attr_accessor :show_unchanged
    attr_accessor :unchanged_context
    attr_accessor :always_show_order
    attr_accessor :never_show_order
    attr_accessor :show_unchanged_columns
    attr_accessor :unchanged_column_context
    attr_accessor :always_show_header
    attr_accessor :acts
    attr_accessor :ids
    attr_accessor :columns_to_ignore
    attr_accessor :allow_nested_cells
    
    def filter(act,allow)
      if @acts == nil 
        @acts = {}
        @acts["update"] = !allow
        @acts["insert"] = !allow
        @acts["delete"] = !allow
      end
      return false if !@acts.include?(act)
      @acts[act] = allow
      return true
    end
    
    def allow_update 
      return true if @acts == nil
      return @acts.include?("update")
    end
    
    def allow_insert 
      return true if @acts == nil
      return @acts.include?("insert")
    end
    
    def allow_delete 
      return true if @acts == nil
      return @acts.include?("delete")
    end
    
    def get_ignored_columns 
      return nil if @columns_to_ignore == nil
      ignore = {}
      begin
        _g1 = 0
        _g = @columns_to_ignore.length
        while(_g1 < _g) 
          i = _g1
          _g1+=1
          ignore[@columns_to_ignore[i]] = true
        end
      end
      return ignore
    end
    
    def add_primary_key(column)
      @ids = Array.new if @ids == nil
      @ids.push(column)
    end
    
    def ignore_column(column)
      @columns_to_ignore = Array.new if @columns_to_ignore == nil
      @columns_to_ignore.push(column)
    end
    
  haxe_me ["coopy", "CompareFlags"]
  end

end
