#!/usr/bin/env ruby
# encoding: utf-8

  class Reflect 
    
    def Reflect.field(o,field)
      begin
        result = o[field]
        result = o[field.to_sym] if result == nil
        return result
      rescue => e
        e = hx_rescued(e)
        return field
      end
    end
    
    def Reflect.fields(o)
      if o.respond_to?("attributes") 
        return o.attributes
      else 
        return o.keys
      end
    end
    
    def Reflect.is_function(f)
      return f.respond_to?("call")
    end
    
  haxe_me ["Reflect"]
  end

