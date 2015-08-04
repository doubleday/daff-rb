#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class IndexPair 
    
    def initialize
      @ia = ::Coopy::Index.new
      @ib = ::Coopy::Index.new
      @quality = 0
    end
    
    protected
    
    attr_accessor :ia
    attr_accessor :ib
    attr_accessor :quality
    
    public
    
    def add_columns(ca,cb)
      @ia.add_column(ca)
      @ib.add_column(cb)
    end
    
    def index_tables(a,b)
      @ia.index_table(a)
      @ib.index_table(b)
      good = 0
      _it = ::Rb::RubyIterator.new(@ia.items.keys)
      while(_it.has_next) do
        key = _it._next
        item_a = @ia.items[key]
        spot_a = item_a.lst.length
        item_b = @ib.items[key]
        spot_b = 0
        spot_b = item_b.lst.length if item_b != nil
        good+=1 if spot_a == 1 && spot_b == 1
      end
      @quality = good / lambda{|_this_| b1 = a.get_height
      _r2 = [1.0,b1].max}.call(self)
    end
    
    protected
    
    def query_by_key(ka)
      result = ::Coopy::CrossMatch.new
      result.item_a = @ia.items[ka]
      result.item_b = @ib.items[ka]
      result.spot_a = result.spot_b = 0
      if ka != "" 
        result.spot_a = result.item_a.lst.length if result.item_a != nil
        result.spot_b = result.item_b.lst.length if result.item_b != nil
      end
      return result
    end
    
    public
    
    def query_by_content(row)
      result = ::Coopy::CrossMatch.new
      ka = @ia.to_key_by_content(row)
      return self.query_by_key(ka)
    end
    
    def query_local(row)
      ka = @ia.to_key(@ia.get_table,row)
      return self.query_by_key(ka)
    end
    
    def local_key(row)
      return @ia.to_key(@ia.get_table,row)
    end
    
    def remote_key(row)
      return @ib.to_key(@ib.get_table,row)
    end
    
    def get_top_freq 
      return @ib.top_freq if @ib.top_freq > @ia.top_freq
      return @ia.top_freq
    end
    
    def get_quality 
      return @quality
    end
    
  haxe_me ["coopy", "IndexPair"]
  end

end
