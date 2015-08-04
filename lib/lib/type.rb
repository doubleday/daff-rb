#!/usr/bin/env ruby
# encoding: utf-8

  class Type 
    
    def Type._typeof(v)
      return ValueType.tnull if v == nil
      begin
        _g = v.class.to_s
        case(_g)
        when "TrueClass"
          return ValueType.tbool
        when "FalseClass"
          return ValueType.tbool
        when "String"
          return ValueType.tclass(String)
        when "Fixnum"
          return ValueType.tint
        when "Float"
          return ValueType.tfloat
        when "Proc"
          return ValueType.tfunction
        when "Array"
          return ValueType.tclass(Array)
        when "Hash"
          return ValueType.tobject
        else
          return ValueType.tenum(v.class) if v.respond_to?("ISENUM__")
          return ValueType.tclass(v.class) if v.respond_to?("class")
          return ValueType.tunknown
        end
      end
    end
    
  haxe_me ["Type"]
  end

