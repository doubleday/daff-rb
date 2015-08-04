#!/usr/bin/env ruby
# encoding: utf-8

module Haxe
module Format
  class JsonParser 
    
    def initialize(str)
      @str = str
      @pos = 0
    end
    
    # protected - in ruby this doesn't play well with static/inline methods
    
    attr_accessor :str
    attr_accessor :pos
    
    def parse_rec 
      while(true) 
        c = nil
        begin
          index = @pos
          @pos+=1
          c = (@str[index] || 0).ord
        end
        case(c)
        when 32,13,10,9
        when 123
          obj = { }
          field = nil
          comma = nil
          while(true) 
            c1 = nil
            begin
              index1 = @pos
              @pos+=1
              c1 = (@str[index1] || 0).ord
            end
            case(c1)
            when 32,13,10,9
            when 125
              self.invalid_char if field != nil || comma == false
              return obj
            when 58
              self.invalid_char if field == nil
              begin
                value = self.parse_rec
                obj[field] = value
              end
              field = nil
              comma = true
            when 44
              if comma 
                comma = false
              else 
                self.invalid_char
              end
            when 34
              self.invalid_char if comma
              field = self.parse_string
            else
              self.invalid_char
            end
          end
        when 91
          arr = []
          comma1 = nil
          while(true) 
            c2 = nil
            begin
              index2 = @pos
              @pos+=1
              c2 = (@str[index2] || 0).ord
            end
            case(c2)
            when 32,13,10,9
            when 93
              self.invalid_char if comma1 == false
              return arr
            when 44
              if comma1 
                comma1 = false
              else 
                self.invalid_char
              end
            else
              self.invalid_char if comma1
              @pos-=1
              arr.push(self.parse_rec)
              comma1 = true
            end
          end
        when 116
          save = @pos
          if lambda{|_this_| index3 = @pos
          @pos+=1
          _r = (@str[index3] || 0).ord}.call(self) != 114 || lambda{|_this_| index4 = @pos
          @pos+=1
          _r2 = (@str[index4] || 0).ord}.call(self) != 117 || lambda{|_this_| index5 = @pos
          @pos+=1
          _r3 = (@str[index5] || 0).ord}.call(self) != 101 
            @pos = save
            self.invalid_char
          end
          return true
        when 102
          save1 = @pos
          if lambda{|_this_| index6 = @pos
          @pos+=1
          _r4 = (@str[index6] || 0).ord}.call(self) != 97 || lambda{|_this_| index7 = @pos
          @pos+=1
          _r5 = (@str[index7] || 0).ord}.call(self) != 108 || lambda{|_this_| index8 = @pos
          @pos+=1
          _r6 = (@str[index8] || 0).ord}.call(self) != 115 || lambda{|_this_| index9 = @pos
          @pos+=1
          _r7 = (@str[index9] || 0).ord}.call(self) != 101 
            @pos = save1
            self.invalid_char
          end
          return false
        when 110
          save2 = @pos
          if lambda{|_this_| index10 = @pos
          @pos+=1
          _r8 = (@str[index10] || 0).ord}.call(self) != 117 || lambda{|_this_| index11 = @pos
          @pos+=1
          _r9 = (@str[index11] || 0).ord}.call(self) != 108 || lambda{|_this_| index12 = @pos
          @pos+=1
          _r10 = (@str[index12] || 0).ord}.call(self) != 108 
            @pos = save2
            self.invalid_char
          end
          return nil
        when 34
          return self.parse_string
        when 48,49,50,51,52,53,54,55,56,57,45
          c3 = c
          start = @pos - 1
          minus = c3 == 45
          digit = !minus
          zero = c3 == 48
          point = false
          e = false
          pm = false
          _end = false
          while(true) 
            begin
              index13 = @pos
              @pos+=1
              c3 = (@str[index13] || 0).ord
            end
            case(c3)
            when 48
              self.invalid_number(start) if zero && !point
              if minus 
                minus = false
                zero = true
              end
              digit = true
            when 49,50,51,52,53,54,55,56,57
              self.invalid_number(start) if zero && !point
              minus = false if minus
              digit = true
              zero = false
            when 46
              self.invalid_number(start) if minus || point
              digit = false
              point = true
            when 101,69
              self.invalid_number(start) if minus || zero || e
              digit = false
              e = true
            when 43,45
              self.invalid_number(start) if !e || pm
              digit = false
              pm = true
            else
              self.invalid_number(start) if !digit
              @pos-=1
              _end = true
            end
            break if _end
          end
          f = nil
          begin
            x = @str[start,@pos - start]
            f = x.to_f
          end
          i = f.to_i
          if i == f 
            return i
          else 
            return f
          end
        else
          self.invalid_char
        end
      end
    end
    
    def parse_string 
      start = @pos
      buf_b = ""
      while(true) 
        c = nil
        begin
          index = @pos
          @pos+=1
          c = (@str[index] || 0).ord
        end
        break if c == 34
        if c == 92 
          buf_b += @str[start,@pos - start - 1]
          begin
            index1 = @pos
            @pos+=1
            c = (@str[index1] || 0).ord
          end
          case(c)
          when 114
            buf_b += [13].pack("U")
          when 110
            buf_b += [10].pack("U")
          when 116
            buf_b += [9].pack("U")
          when 98
            buf_b += [8].pack("U")
          when 102
            buf_b += [12].pack("U")
          when 47,92,34
            buf_b += [c].pack("U")
          when 117
            uc = nil
            begin
              x = "0x" + _hx_str(@str[@pos,4])
              uc = x.to_i
            end
            @pos += 4
            buf_b += [uc].pack("U")
          else
            raise hx_raise("Invalid escape sequence \\" + _hx_str([c].pack("U")) + " at position " + _hx_str((@pos - 1)))
          end
          start = @pos
        elsif c == 0 
          raise hx_raise("Unclosed string")
        end
      end
      buf_b += @str[start,@pos - start - 1]
      return buf_b
    end
    
    def invalid_char 
      @pos-=1
      raise hx_raise("Invalid char " + _hx_str((@str[@pos] || 0).ord) + " at position " + _hx_str(@pos))
    end
    
    def invalid_number(start)
      raise hx_raise("Invalid number at position " + _hx_str(start) + ": " + _hx_str(@str[start,@pos - start]))
    end
    
  haxe_me ["haxe", "format", "JsonParser"]
  end

end
end
