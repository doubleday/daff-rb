#!/usr/bin/env ruby
# encoding: utf-8

  class ValueType
    ISENUM__ = true
    attr_accessor :tag
    attr_accessor :index
    attr_accessor :params
    def initialize(t,index,p = nil ) @tag = t; @index = index; @params = p; end
    
    def ValueType.tbool() ValueType.new("TBool",3) end
    def ValueType.tclass(c)  ValueType.new("TClass",6,[c]) end
    def ValueType.tenum(e)  ValueType.new("TEnum",7,[e]) end
    def ValueType.tfloat() ValueType.new("TFloat",2) end
    def ValueType.tfunction() ValueType.new("TFunction",5) end
    def ValueType.tint() ValueType.new("TInt",1) end
    def ValueType.tnull() ValueType.new("TNull",0) end
    def ValueType.tobject() ValueType.new("TObject",4) end
    def ValueType.tunknown() ValueType.new("TUnknown",8) end
    CONSTRUCTS__ = ["TNull","TInt","TFloat","TBool","TObject","TFunction","TClass","TEnum","TUnknown"]
    def ==(a) (!a.nil?) && (a.respond_to? 'ISENUM__') && a.tag === @tag && a.index === @index && a.params == @params end
  end

