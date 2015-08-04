#!/usr/bin/env ruby
# encoding: utf-8

module Haxe
module Format
  class JsonPrinter 
    
    def initialize(replacer,space)
      @replacer = replacer
      @indent = space
      @pretty = space != nil
      @nind = 0
      @buf = StringBuf.new
    end
    
    # protected - in ruby this doesn't play well with static/inline methods
    
    attr_accessor :buf
    attr_accessor :replacer
    attr_accessor :indent
    attr_accessor :pretty
    attr_accessor :nind
    
    def write(k,v)
      v = (@replacer).call(k,v) if @replacer != nil
      begin
        _g = Type._typeof(v)
        case(_g.index)
        when 8
          @buf.b += "\"???\"".to_s
        when 4
          self.fields_string(v,Reflect.fields(v))
        when 1
          v1 = v
          @buf.b += v1.to_s
        when 2
          v2 = nil
          if lambda{|_this_| f = v
          _r = f.to_f.finite?}.call(self) 
            v2 = v
          else 
            v2 = "null"
          end
          @buf.b += v2.to_s
        when 5
          @buf.b += "\"<fun>\"".to_s
        when 6
          c = _g.params[0]
          if c == String 
            self.quote(v)
          elsif c == Array 
            v3 = v
            @buf.b += [91].pack("U")
            len = v3.length
            last = len - 1
            begin
              _g1 = 0
              while(_g1 < len) 
                i = _g1
                _g1+=1
                if i > 0 
                  @buf.b += [44].pack("U")
                else 
                  @nind+=1
                end
                @buf.b += [10].pack("U") if @pretty
                if @pretty 
                  v4 = nil
                  begin
                    c1 = @indent
                    l = @nind * @indent.length
                    if c1.length == 0 || "".length >= l 
                      v4 = ""
                    else 
                      v4 = str_pad("",((l - "".length) / c1.length).ceil * c1.length + "".length,c1,__php__.call("STR_PAD_LEFT"))
                    end
                  end
                  @buf.b += v4.to_s
                end
                self.write(i,v3[i])
                if i == last 
                  @nind-=1
                  @buf.b += [10].pack("U") if @pretty
                  if @pretty 
                    v5 = nil
                    begin
                      c2 = @indent
                      l1 = @nind * @indent.length
                      if c2.length == 0 || "".length >= l1 
                        v5 = ""
                      else 
                        v5 = str_pad("",((l1 - "".length) / c2.length).ceil * c2.length + "".length,c2,__php__.call("STR_PAD_LEFT"))
                      end
                    end
                    @buf.b += v5.to_s
                  end
                end
              end
            end
            @buf.b += [93].pack("U")
          elsif c == ::Haxe::Ds::StringMap 
            v6 = v
            o = { }
            _it2 = ::Rb::RubyIterator.new(v6.keys)
            while(_it2.has_next) do
              k1 = _it2._next
              value = v6[k1]
              o[k1] = value
            end
            self.fields_string(o,Reflect.fields(o))
          elsif c == Date 
            v7 = v
            self.quote(HxOverrides.date_str(v7))
          else 
            self.fields_string(v,Reflect.fields(v))
          end
        when 7
          i1 = nil
          begin
            e = v
            i1 = e.index
          end
          begin
            v8 = i1
            @buf.b += v8.to_s
          end
        when 3
          v9 = v
          @buf.b += v9.to_s
        when 0
          @buf.b += "null".to_s
        end
      end
    end
    
    def fields_string(v,fields)
      @buf.b += [123].pack("U")
      len = fields.length
      last = len - 1
      first = true
      begin
        _g = 0
        while(_g < len) 
          i = _g
          _g+=1
          f = fields[i]
          value = Reflect.field(v,f)
          next if Reflect.is_function(value)
          if first 
            @nind+=1
            first = false
          else 
            @buf.b += [44].pack("U")
          end
          @buf.b += [10].pack("U") if @pretty
          if @pretty 
            v1 = nil
            begin
              c = @indent
              l = @nind * @indent.length
              if c.length == 0 || "".length >= l 
                v1 = ""
              else 
                v1 = str_pad("",((l - "".length) / c.length).ceil * c.length + "".length,c,__php__.call("STR_PAD_LEFT"))
              end
            end
            @buf.b += v1.to_s
          end
          self.quote(f)
          @buf.b += [58].pack("U")
          @buf.b += [32].pack("U") if @pretty
          self.write(f,value)
          if i == last 
            @nind-=1
            @buf.b += [10].pack("U") if @pretty
            if @pretty 
              v2 = nil
              begin
                c1 = @indent
                l1 = @nind * @indent.length
                if c1.length == 0 || "".length >= l1 
                  v2 = ""
                else 
                  v2 = str_pad("",((l1 - "".length) / c1.length).ceil * c1.length + "".length,c1,__php__.call("STR_PAD_LEFT"))
                end
              end
              @buf.b += v2.to_s
            end
          end
        end
      end
      @buf.b += [125].pack("U")
    end
    
    def quote(s)
      @buf.b += [34].pack("U")
      i = 0
      while(true) 
        c = nil
        begin
          index = i
          i+=1
          c = (s[index] || 0).ord
        end
        break if c == 0
        case(c)
        when 34
          @buf.b += "\\\"".to_s
        when 92
          @buf.b += "\\\\".to_s
        when 10
          @buf.b += "\\n".to_s
        when 13
          @buf.b += "\\r".to_s
        when 9
          @buf.b += "\\t".to_s
        when 8
          @buf.b += "\\b".to_s
        when 12
          @buf.b += "\\f".to_s
        else
          @buf.b += [c].pack("U")
        end
      end
      @buf.b += [34].pack("U")
    end
    
    public
    
    def JsonPrinter._print(o,replacer = nil,space = nil)
      printer = ::Haxe::Format::JsonPrinter.new(replacer,space)
      printer.write("",o)
      return printer.buf.b
    end
    
  haxe_me ["haxe", "format", "JsonPrinter"]
  end

end
end
