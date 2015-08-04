#!/usr/bin/env ruby
# encoding: utf-8

module Coopy
  class TableIO 
    
    def initialize
    end
    
    def get_content(name)
      return ::Sys::Io::HxFile.get_content(name)
    end
    
    def save_content(name,txt)
      ::Sys::Io::HxFile.save_content(name,txt)
      return true
    end
    
    def args 
      return HxSys.args
    end
    
    def write_stdout(txt)
      HxSys.stdout.write_string(txt)
    end
    
    def write_stderr(txt)
      HxSys.stderr.write_string(txt)
    end
    
    def command(cmd,args)
      begin
        return HxSys.command(cmd,args)
      rescue => e
        e = hx_rescued(e)
        return 1
      end
    end
    
    def async 
      return false
    end
    
    def exists(path)
      return File.exist?(path)
    end
    
    def open_sqlite_database(path)
      return nil
    end
    
  haxe_me ["coopy", "TableIO"]
  end

end
