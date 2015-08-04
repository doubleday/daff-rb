#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class SqlDatabase 
    def getColumns(name) puts "Abstract SqlDatabase.getColumns called" end
    def getQuotedTableName(name) puts "Abstract SqlDatabase.getQuotedTableName called" end
    def getQuotedColumnName(name) puts "Abstract SqlDatabase.getQuotedColumnName called" end
    def begin(query,args = nil,order = nil) puts "Abstract SqlDatabase.begin called" end
    def beginRow(name,row,order = nil) puts "Abstract SqlDatabase.beginRow called" end
    def read() puts "Abstract SqlDatabase.read called" end
    def get(index) puts "Abstract SqlDatabase.get called" end
    def end() puts "Abstract SqlDatabase.end called" end
    def width() puts "Abstract SqlDatabase.width called" end
    def rowid() puts "Abstract SqlDatabase.rowid called" end
  haxe_me ["coopy", "SqlDatabase"]
  end

end
