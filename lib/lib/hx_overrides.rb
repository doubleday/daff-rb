#!/usr/bin/env ruby
# encoding: utf-8

  class HxOverrides 
    
    # protected - in ruby this doesn't play well with static/inline methods
    
    def HxOverrides.date_str(date)
      m = date.get_month + 1
      d = date.get_date
      h = date.get_hours
      mi = date.get_minutes
      s = date.get_seconds
      return _hx_str(date.get_full_year) + "-" + _hx_str((((m < 10) ? "0" + _hx_str(m) : "" + _hx_str(m)))) + "-" + _hx_str((((d < 10) ? "0" + _hx_str(d) : "" + _hx_str(d)))) + " " + _hx_str((((h < 10) ? "0" + _hx_str(h) : "" + _hx_str(h)))) + ":" + _hx_str((((mi < 10) ? "0" + _hx_str(mi) : "" + _hx_str(mi)))) + ":" + _hx_str((((s < 10) ? "0" + _hx_str(s) : "" + _hx_str(s))))
    end
    
  haxe_me ["HxOverrides"]
  end

