#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class SqlCompare 
    
    def initialize(db,local,remote)
      @db = db
      @local = local
      @remote = remote
    end
    
    attr_accessor :db
    attr_accessor :parent
    attr_accessor :local
    attr_accessor :remote
    
    protected
    
    attr_accessor :at0
    attr_accessor :at1
    attr_accessor :align
    
    def equal_array(a1,a2)
      return false if a1.length != a2.length
      begin
        _g1 = 0
        _g = a1.length
        while(_g1 < _g) 
          i = _g1
          _g1+=1
          return false if a1[i] != a2[i]
        end
      end
      return true
    end
    
    public
    
    def validate_schema 
      all_cols1 = @local.get_column_names
      all_cols2 = @remote.get_column_names
      return false if !self.equal_array(all_cols1,all_cols2)
      key_cols1 = @local.get_primary_key
      key_cols2 = @remote.get_primary_key
      return false if !self.equal_array(key_cols1,key_cols2)
      return false if key_cols1.length == 0
      return true
    end
    
    protected
    
    def denull(x)
      return -1 if x == nil
      return x
    end
    
    def link 
      i0 = self.denull(@db.get(0))
      i1 = self.denull(@db.get(1))
      if i0 == -3 
        i0 = @at0
        @at0+=1
      end
      if i1 == -3 
        i1 = @at1
        @at1+=1
      end
      factor = nil
      if i0 >= 0 && i1 >= 0 
        factor = 2
      else 
        factor = 1
      end
      offset = factor - 1
      if i0 >= 0 
        _g1 = 0
        _g = @local.get_width
        while(_g1 < _g) 
          x = _g1
          _g1+=1
          @local.set_cell_cache(x,i0,@db.get(2 + factor * x))
        end
      end
      if i1 >= 0 
        _g11 = 0
        _g2 = @remote.get_width
        while(_g11 < _g2) 
          x1 = _g11
          _g11+=1
          @remote.set_cell_cache(x1,i1,@db.get(2 + factor * x1 + offset))
        end
      end
      @align.link(i0,i1)
      @align.add_to_order(i0,i1)
    end
    
    def link_query(query,order)
      if @db._begin(query,nil,order) 
        while(@db.read) 
          self.link
        end
        @db._end
      end
    end
    
    public
    
    def apply 
      return nil if @db == nil
      return nil if !self.validate_schema
      rowid_name = @db.rowid
      @align = ::Coopy::Alignment.new
      key_cols = @local.get_primary_key
      data_cols = @local.get_all_but_primary_key
      all_cols = @local.get_column_names
      @align.meta = ::Coopy::Alignment.new
      begin
        _g1 = 0
        _g = all_cols.length
        while(_g1 < _g) 
          i = _g1
          _g1+=1
          @align.meta.link(i,i)
        end
      end
      @align.meta.range(all_cols.length,all_cols.length)
      @align.tables(@local,@remote)
      @align.range(999,999)
      sql_table1 = @local.get_quoted_table_name
      sql_table2 = @remote.get_quoted_table_name
      sql_key_cols = ""
      begin
        _g11 = 0
        _g2 = key_cols.length
        while(_g11 < _g2) 
          i1 = _g11
          _g11+=1
          sql_key_cols += "," if i1 > 0
          sql_key_cols += @local.get_quoted_column_name(key_cols[i1])
        end
      end
      sql_all_cols = ""
      begin
        _g12 = 0
        _g3 = all_cols.length
        while(_g12 < _g3) 
          i2 = _g12
          _g12+=1
          sql_all_cols += "," if i2 > 0
          sql_all_cols += @local.get_quoted_column_name(all_cols[i2])
        end
      end
      sql_key_match = ""
      begin
        _g13 = 0
        _g4 = key_cols.length
        while(_g13 < _g4) 
          i3 = _g13
          _g13+=1
          sql_key_match += " AND " if i3 > 0
          n = @local.get_quoted_column_name(key_cols[i3])
          sql_key_match += _hx_str(sql_table1) + "." + _hx_str(n) + " IS " + _hx_str(sql_table2) + "." + _hx_str(n)
        end
      end
      sql_data_mismatch = ""
      begin
        _g14 = 0
        _g5 = data_cols.length
        while(_g14 < _g5) 
          i4 = _g14
          _g14+=1
          sql_data_mismatch += " OR " if i4 > 0
          n1 = @local.get_quoted_column_name(data_cols[i4])
          sql_data_mismatch += _hx_str(sql_table1) + "." + _hx_str(n1) + " IS NOT " + _hx_str(sql_table2) + "." + _hx_str(n1)
        end
      end
      sql_dbl_cols = ""
      dbl_cols = []
      begin
        _g15 = 0
        _g6 = all_cols.length
        while(_g15 < _g6) 
          i5 = _g15
          _g15+=1
          sql_dbl_cols += "," if i5 > 0
          n2 = @local.get_quoted_column_name(all_cols[i5])
          buf = "__coopy_" + _hx_str(i5)
          sql_dbl_cols += _hx_str(sql_table1) + "." + _hx_str(n2) + " AS " + _hx_str(buf)
          dbl_cols.push(buf)
          sql_dbl_cols += ","
          sql_dbl_cols += _hx_str(sql_table2) + "." + _hx_str(n2) + " AS " + _hx_str(buf) + "b"
          dbl_cols.push(_hx_str(buf) + "b")
        end
      end
      sql_order = ""
      begin
        _g16 = 0
        _g7 = key_cols.length
        while(_g16 < _g7) 
          i6 = _g16
          _g16+=1
          sql_order += "," if i6 > 0
          n3 = @local.get_quoted_column_name(key_cols[i6])
          sql_order += n3
        end
      end
      sql_dbl_order = ""
      begin
        _g17 = 0
        _g8 = key_cols.length
        while(_g17 < _g8) 
          i7 = _g17
          _g17+=1
          sql_dbl_order += "," if i7 > 0
          n4 = @local.get_quoted_column_name(key_cols[i7])
          sql_dbl_order += _hx_str(sql_table1) + "." + _hx_str(n4)
        end
      end
      rowid = "-3"
      rowid1 = "-3"
      rowid2 = "-3"
      if rowid_name != nil 
        rowid = rowid_name
        rowid1 = _hx_str(sql_table1) + "." + _hx_str(rowid_name)
        rowid2 = _hx_str(sql_table2) + "." + _hx_str(rowid_name)
      end
      sql_inserts = "SELECT DISTINCT NULL, " + _hx_str(rowid) + " AS rowid, " + _hx_str(sql_all_cols) + " FROM " + _hx_str(sql_table2) + " WHERE NOT EXISTS (SELECT 1 FROM " + _hx_str(sql_table1) + " WHERE " + _hx_str(sql_key_match) + ")"
      sql_inserts_order = ["NULL","rowid"].concat(all_cols)
      sql_updates = "SELECT DISTINCT " + _hx_str(rowid1) + " AS __coopy_rowid0, " + _hx_str(rowid2) + " AS __coopy_rowid1, " + _hx_str(sql_dbl_cols) + " FROM " + _hx_str(sql_table1) + " INNER JOIN " + _hx_str(sql_table2) + " ON " + _hx_str(sql_key_match) + " WHERE " + _hx_str(sql_data_mismatch)
      sql_updates_order = ["__coopy_rowid0","__coopy_rowid1"].concat(dbl_cols)
      sql_deletes = "SELECT DISTINCT " + _hx_str(rowid) + " AS rowid, NULL, " + _hx_str(sql_all_cols) + " FROM " + _hx_str(sql_table1) + " WHERE NOT EXISTS (SELECT 1 FROM " + _hx_str(sql_table2) + " WHERE " + _hx_str(sql_key_match) + ")"
      sql_deletes_order = ["rowid","NULL"].concat(all_cols)
      @at0 = 1
      @at1 = 1
      self.link_query(sql_inserts,sql_inserts_order)
      self.link_query(sql_updates,sql_updates_order)
      self.link_query(sql_deletes,sql_deletes_order)
      return @align
    end
    
  haxe_me ["coopy", "SqlCompare"]
  end

end
