#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class SqlHelper 
    def getTableNames(db) puts "Abstract SqlHelper.getTableNames called" end
    def countRows(db,name) puts "Abstract SqlHelper.countRows called" end
    def getRowIDs(db,name) puts "Abstract SqlHelper.getRowIDs called" end
  haxe_me ["coopy", "SqlHelper"]
  end

end
