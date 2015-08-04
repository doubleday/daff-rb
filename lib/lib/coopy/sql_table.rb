#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class SqlTable 
    
    def initialize(db,name,helper = nil)
      @db = db
      @name = name
      @helper = helper
      @cache = {}
      @h = -1
      @id2rid = nil
      self.get_columns
    end
    
    protected
    
    attr_accessor :db
    attr_accessor :columns
    attr_accessor :name
    attr_accessor :quoted_table_name
    attr_accessor :cache
    attr_accessor :column_names
    attr_accessor :h
    attr_accessor :helper
    attr_accessor :id2rid
    
    def get_columns 
      return if @columns != nil
      return if @db == nil
      @columns = @db.get_columns(@name)
      @column_names = Array.new
      begin
        _g = 0
        _g1 = @columns
        while(_g < _g1.length) 
          col = _g1[_g]
          _g+=1
          @column_names.push(col.get_name)
        end
      end
    end
    
    public
    
    def get_primary_key 
      self.get_columns
      result = Array.new
      begin
        _g = 0
        _g1 = @columns
        while(_g < _g1.length) 
          col = _g1[_g]
          _g+=1
          next if !col.is_primary_key
          result.push(col.get_name)
        end
      end
      return result
    end
    
    def get_all_but_primary_key 
      self.get_columns
      result = Array.new
      begin
        _g = 0
        _g1 = @columns
        while(_g < _g1.length) 
          col = _g1[_g]
          _g+=1
          next if col.is_primary_key
          result.push(col.get_name)
        end
      end
      return result
    end
    
    def get_column_names 
      self.get_columns
      return @column_names
    end
    
    def get_quoted_table_name 
      return @quoted_table_name if @quoted_table_name != nil
      @quoted_table_name = @db.get_quoted_table_name(@name)
      return @quoted_table_name
    end
    
    def get_quoted_column_name(name)
      return @db.get_quoted_column_name(name)
    end
    
    def get_cell(x,y)
      if @h >= 0 
        y = y - 1
        y = @id2rid[y] if y >= 0
      end
      if y < 0 
        self.get_columns
        return @columns[x].name
      end
      row = @cache[y]
      if row == nil 
        row = {}
        self.get_columns
        @db.begin_row(@name,y,@column_names)
        while(@db.read) 
          _g1 = 0
          _g = self.get_width
          while(_g1 < _g) 
            i = _g1
            _g1+=1
            begin
              v = @db.get(i)
              begin
                value = v
                row[i] = value
              end
              v
            end
          end
        end
        @db._end
        begin
          @cache[y] = row
          row
        end
      end
      begin
        this1 = @cache[y]
        return this1.get(x)
      end
    end
    
    def set_cell_cache(x,y,c)
      row = @cache[y]
      if row == nil 
        row = {}
        self.get_columns
        begin
          @cache[y] = row
          row
        end
      end
      begin
        v = c
        begin
          value = v
          row[x] = value
        end
        v
      end
    end
    
    def set_cell(x,y,c)
      puts "SqlTable cannot set cells yet"
    end
    
    def get_cell_view 
      return ::Coopy::SimpleView.new
    end
    
    def is_resizable 
      return false
    end
    
    def resize(w,h)
      return false
    end
    
    def clear 
    end
    
    def insert_or_delete_rows(fate,hfate)
      return false
    end
    
    def insert_or_delete_columns(fate,wfate)
      return false
    end
    
    def trim_blank 
      return false
    end
    
    def height() get_height end
    def height=(__v) @height = __v end
    def width() get_width end
    def width=(__v) @width = __v end
    
    def get_width 
      self.get_columns
      return @columns.length
    end
    
    def get_height 
      return @h if @h >= 0
      return -1 if @helper == nil
      @id2rid = @helper.get_row_ids(@db,@name)
      @h = @id2rid.length + 1
      return @h
    end
    
    def get_data 
      return nil
    end
    
    def clone 
      return nil
    end
    
  haxe_me ["coopy", "SqlTable"]
  end

end
