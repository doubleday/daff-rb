#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class CellBuilder 
    def needSeparator() puts "Abstract CellBuilder.needSeparator called" end
    def setSeparator(separator) puts "Abstract CellBuilder.setSeparator called" end
    def setConflictSeparator(separator) puts "Abstract CellBuilder.setConflictSeparator called" end
    def setView(view) puts "Abstract CellBuilder.setView called" end
    def update(local,remote) puts "Abstract CellBuilder.update called" end
    def conflict(parent,local,remote) puts "Abstract CellBuilder.conflict called" end
    def marker(label) puts "Abstract CellBuilder.marker called" end
    def links(unit) puts "Abstract CellBuilder.links called" end
  haxe_me ["coopy", "CellBuilder"]
  end

end
