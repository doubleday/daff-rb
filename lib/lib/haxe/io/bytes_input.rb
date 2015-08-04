#!/usr/bin/env ruby
# encoding: utf-8

module Haxe
module Io
  class BytesInput < ::Haxe::Io::Input 
    attr_accessor :position
    attr_accessor :length
  haxe_me
  end

end
end
