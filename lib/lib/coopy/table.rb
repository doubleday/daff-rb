#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class Table 
    def getCell(x,y) puts "Abstract Table.getCell called" end
    def setCell(x,y,c) puts "Abstract Table.setCell called" end
    def getCellView() puts "Abstract Table.getCellView called" end
    def isResizable() puts "Abstract Table.isResizable called" end
    def resize(w,h) puts "Abstract Table.resize called" end
    def clear() puts "Abstract Table.clear called" end
    def insertOrDeleteRows(fate,hfate) puts "Abstract Table.insertOrDeleteRows called" end
    def insertOrDeleteColumns(fate,wfate) puts "Abstract Table.insertOrDeleteColumns called" end
    def trimBlank() puts "Abstract Table.trimBlank called" end
    def get_width() puts "Abstract Table.get_width called" end
    def get_height() puts "Abstract Table.get_height called" end
    def getData() puts "Abstract Table.getData called" end
    def clone() puts "Abstract Table.clone called" end
  haxe_me ["coopy", "Table"]
  end

end
