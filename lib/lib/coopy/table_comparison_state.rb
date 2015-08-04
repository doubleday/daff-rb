#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class TableComparisonState 
    
    def initialize
      self.reset
    end
    
    attr_accessor :p
    attr_accessor :a
    attr_accessor :b
    attr_accessor :completed
    attr_accessor :run_to_completion
    attr_accessor :is_equal
    attr_accessor :is_equal_known
    attr_accessor :has_same_columns
    attr_accessor :has_same_columns_known
    attr_accessor :compare_flags
    
    def reset 
      @completed = false
      @run_to_completion = true
      @is_equal_known = false
      @is_equal = false
      @has_same_columns = false
      @has_same_columns_known = false
      @compare_flags = nil
    end
    
  haxe_me ["coopy", "TableComparisonState"]
  end

end
