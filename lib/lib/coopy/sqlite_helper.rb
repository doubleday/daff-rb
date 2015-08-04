#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class SqliteHelper 
    
    def initialize
    end
    
    def get_table_names(db)
      q = "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name"
      return nil if !db._begin(q,nil,["name"])
      names = Array.new
      while(db.read) 
        names.push(db.get(0))
      end
      db._end
      return names
    end
    
    def count_rows(db,name)
      q = "SELECT COUNT(*) AS ct FROM " + _hx_str(db.get_quoted_table_name(name))
      return -1 if !db._begin(q,nil,["ct"])
      ct = -1
      while(db.read) 
        ct = db.get(0)
      end
      db._end
      return ct
    end
    
    def get_row_ids(db,name)
      result = Array.new
      q = "SELECT ROWID AS r FROM " + _hx_str(db.get_quoted_table_name(name)) + " ORDER BY ROWID"
      return nil if !db._begin(q,nil,["r"])
      while(db.read) 
        c = db.get(0)
        result.push(c)
      end
      db._end
      return result
    end
    
  haxe_me ["coopy", "SqliteHelper"]
  end

end
