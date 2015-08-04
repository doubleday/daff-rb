#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class Viterbi 
    
    def initialize
      @k = @t = 0
      self.reset
      @cost = ::Coopy::SparseSheet.new
      @src = ::Coopy::SparseSheet.new
      @path = ::Coopy::SparseSheet.new
    end
    
    protected
    
    attr_accessor :k
    attr_accessor :t
    attr_accessor :index
    attr_accessor :mode
    attr_accessor :path_valid
    attr_accessor :best_cost
    attr_accessor :cost
    attr_accessor :src
    attr_accessor :path
    
    public
    
    def reset 
      @index = 0
      @mode = 0
      @path_valid = false
      @best_cost = 0
    end
    
    def set_size(states,sequence_length)
      @k = states
      @t = sequence_length
      @cost.resize(@k,@t,0)
      @src.resize(@k,@t,-1)
      @path.resize(1,@t,-1)
    end
    
    protected
    
    def assert_mode(_next)
      @index+=1 if _next == 0 && @mode == 1
      @mode = _next
    end
    
    public
    
    def add_transition(s0,s1,c)
      resize = false
      if s0 >= @k 
        @k = s0 + 1
        resize = true
      end
      if s1 >= @k 
        @k = s1 + 1
        resize = true
      end
      if resize 
        @cost.non_destructive_resize(@k,@t,0)
        @src.non_destructive_resize(@k,@t,-1)
        @path.non_destructive_resize(1,@t,-1)
      end
      @path_valid = false
      self.assert_mode(1)
      if @index >= @t 
        @t = @index + 1
        @cost.non_destructive_resize(@k,@t,0)
        @src.non_destructive_resize(@k,@t,-1)
        @path.non_destructive_resize(1,@t,-1)
      end
      sourced = false
      if @index > 0 
        c += @cost.get(s0,@index - 1)
        sourced = @src.get(s0,@index - 1) != -1
      else 
        sourced = true
      end
      if sourced 
        if c < @cost.get(s1,@index) || @src.get(s1,@index) == -1 
          @cost.set(s1,@index,c)
          @src.set(s1,@index,s0)
        end
      end
    end
    
    def end_transitions 
      @path_valid = false
      self.assert_mode(0)
    end
    
    def begin_transitions 
      @path_valid = false
      self.assert_mode(1)
    end
    
    def calculate_path 
      return if @path_valid
      self.end_transitions
      best = 0
      bestj = -1
      if @index <= 0 
        @path_valid = true
        return
      end
      begin
        _g1 = 0
        _g = @k
        while(_g1 < _g) 
          j = _g1
          _g1+=1
          if (@cost.get(j,@index - 1) < best || bestj == -1) && @src.get(j,@index - 1) != -1 
            best = @cost.get(j,@index - 1)
            bestj = j
          end
        end
      end
      @best_cost = best
      begin
        _g11 = 0
        _g2 = @index
        while(_g11 < _g2) 
          j1 = _g11
          _g11+=1
          i = @index - 1 - j1
          @path.set(0,i,bestj)
          puts "Problem in Viterbi" if !(bestj != -1 && (bestj >= 0 && bestj < @k))
          bestj = @src.get(bestj,i)
        end
      end
      @path_valid = true
    end
    
    def to_s 
      self.calculate_path
      txt = ""
      begin
        _g1 = 0
        _g = @index
        while(_g1 < _g) 
          i = _g1
          _g1+=1
          if @path.get(0,i) == -1 
            txt += "*"
          else 
            txt += @path.get(0,i)
          end
          txt += " " if @k >= 10
        end
      end
      txt += " costs " + _hx_str(self.get_cost)
      return txt
    end
    
    def length 
      self.calculate_path if @index > 0
      return @index
    end
    
    def get(i)
      self.calculate_path
      return @path.get(0,i)
    end
    
    def get_cost 
      self.calculate_path
      return @best_cost
    end
    
  haxe_me ["coopy", "Viterbi"]
  end

end
