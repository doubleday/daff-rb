#!/usr/bin/env ruby
# encoding: utf-8

module Sys
module Io
  class HxFile 
    
    def HxFile.get_content(path)
      return IO.read(path)
    end
    
    def HxFile.save_content(path,content)
      IO.write(path,content)
    end
    
  haxe_me ["sys", "io", "File"]
  end

end
end
