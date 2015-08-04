#!/usr/bin/env ruby
# encoding: utf-8

  class HxSys 
    
    def HxSys.args 
      return ARGV
    end
    
    # protected - in ruby this doesn't play well with static/inline methods
    
    def HxSys.escape_argument(arg)
      ok = true
      begin
        _g1 = 0
        _g = arg.length
        while(_g1 < _g) 
          i = _g1
          _g1+=1
          _g2 = (arg[i].ord rescue nil)
          case(_g2)
          when 32,34
            ok = false
          when 0,13,10
            arg = arg[0,i]
          end if _g2 != nil
        end
      end
      return arg if ok
      return "\"" + _hx_str(arg.split("\"").join("\\\"")) + "\""
    end
    
    public
    
    def HxSys.command(cmd,args = nil)
      if args != nil 
        cmd = HxSys.escape_argument(cmd)
        begin
          _g = 0
          while(_g < args.length) 
            a = args[_g]
            _g+=1
            cmd += " " + _hx_str(HxSys.escape_argument(a))
          end
        end
      end
      result = nil
      if system(cmd) 
        result = 0
      else 
        result = 1
      end
      return result
    end
    
    def HxSys.stdout 
      return ::Sys::Io::FileOutput.new(STDOUT)
    end
    
    def HxSys.stderr 
      return ::Sys::Io::FileOutput.new(STDERR)
    end
    
  haxe_me ["Sys"]
  end

