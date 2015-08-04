#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class TableText 
    
    def initialize(tab)
      @tab = tab
      @view = tab.get_cell_view
    end
    
    protected
    
    attr_accessor :tab
    attr_accessor :view
    
    public
    
    def get_cell_text(x,y)
      return @view.to_s(@tab.get_cell(x,y))
    end
    
  haxe_me
  end

end
