#!/usr/bin/env ruby
# encoding: utf-8

  class Lambda 
    
    def Lambda.array(it)
      a = Array.new
      _it = Rb::RubyIterator.new(it)
      while(_it.has_next) do
        i = _it._next
        a.push(i)
      end
      return a
    end
    
    def Lambda.map(it,f)
      l = List.new
      _it = Rb::RubyIterator.new(it)
      while(_it.has_next) do
        x = _it._next
        l.add((f).call(x))
      end
      return l
    end
    
    def Lambda.has(it,elt)
      _it = Rb::RubyIterator.new(it)
      while(_it.has_next) do
        x = _it._next
        return true if x == elt
      end
      return false
    end
    
  haxe_me ["Lambda"]
  end

