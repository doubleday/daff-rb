#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class View 
    def toString(d) puts "Abstract View.toString called" end
    def equals(d1,d2) puts "Abstract View.equals called" end
    def toDatum(str) puts "Abstract View.toDatum called" end
    def makeHash() puts "Abstract View.makeHash called" end
    def hashSet(h,str,d) puts "Abstract View.hashSet called" end
    def isHash(h) puts "Abstract View.isHash called" end
    def hashExists(h,str) puts "Abstract View.hashExists called" end
    def hashGet(h,str) puts "Abstract View.hashGet called" end
  haxe_me ["coopy", "View"]
  end

end
