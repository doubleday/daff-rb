#!/usr/bin/env ruby
# encoding: utf-8

# Translation requires Ruby >= 1.9.3
ruby_major, ruby_minor, ruby_patch = RUBY_VERSION.split('.').map{|x| x.to_i}
if ruby_major<1 || (ruby_major==1 && (ruby_minor<9 || (ruby_minor==9 && ruby_patch<3)))
  $stderr.puts "Your current Ruby version is: #{RUBY_VERSION}. Haxe/Ruby generates code for version 1.9.3 or later."
  Kernel.exit 1
end
def haxe_me(source_name)
  $hx_types ||= {}
  $hx_types[source_name.join('.')] = self
  _haxe_vars_ = {}
  instance_methods(false).grep(/=$/).grep(/^[^\[=]/).each do |v|
    _haxe_vars_[v.to_s[0..-2].to_sym] = ('@'+v.to_s[0..-2]).to_sym
  end
  old_get = instance_method(:[]) rescue nil
  define_method(:[]) do |x|
    return old_get.bind(self).(x) if x.is_a?(Fixnum)
    return old_get.bind(self).(x) if x.is_a?(Range)
    tag = _haxe_vars_[x]
    return instance_variable_get(tag) if tag
    begin
      method x
    rescue
      raise "Could not haxe #{source_name}, #{x.class}"
    end

  end
  old_set = instance_method(:[]=) rescue nil
  define_method(:[]=) do |x,y|
    return old_set.bind(self).(x,y) if x.is_a?(Fixnum)
    instance_variable_set(_haxe_vars_[x],y)
  end
  define_method(:haxe_name) do
    source_name.join('.')
  end
  class << self
    define_method(:[]) do |x|
      method x
    end
  end
end
class Array
  haxe_me(['Array'])
end

require 'date'
require_relative 'lib/hx_overrides'
require_relative 'lib/lambda'
require_relative 'lib/list'
require_relative 'lib/x_list/list_iterator'
require_relative 'lib/reflect'
require_relative 'lib/string_buf'
require_relative 'lib/hx_sys'
require_relative 'lib/value_type'
require_relative 'lib/type'
require_relative 'lib/coopy/alignment'
require_relative 'lib/coopy/cell_builder'
require_relative 'lib/coopy/cell_info'
require_relative 'lib/coopy/compare_flags'
require_relative 'lib/coopy/compare_table'
require_relative 'lib/coopy/coopy'
require_relative 'lib/coopy/cross_match'
require_relative 'lib/coopy/csv'
require_relative 'lib/coopy/diff_render'
require_relative 'lib/coopy/flat_cell_builder'
require_relative 'lib/coopy/row'
require_relative 'lib/coopy/highlight_patch'
require_relative 'lib/coopy/highlight_patch_unit'
require_relative 'lib/coopy/index'
require_relative 'lib/coopy/index_item'
require_relative 'lib/coopy/index_pair'
require_relative 'lib/coopy/merger'
require_relative 'lib/coopy/mover'
require_relative 'lib/coopy/ndjson'
require_relative 'lib/coopy/nested_cell_builder'
require_relative 'lib/coopy/ordering'
require_relative 'lib/coopy/table'
require_relative 'lib/coopy/simple_table'
require_relative 'lib/coopy/view'
require_relative 'lib/coopy/simple_view'
require_relative 'lib/coopy/sparse_sheet'
require_relative 'lib/coopy/sql_column'
require_relative 'lib/coopy/sql_compare'
require_relative 'lib/coopy/sql_database'
require_relative 'lib/coopy/sql_helper'
require_relative 'lib/coopy/sql_table'
require_relative 'lib/coopy/sql_table_name'
require_relative 'lib/coopy/sqlite_helper'
require_relative 'lib/coopy/table_comparison_state'
require_relative 'lib/coopy/table_diff'
require_relative 'lib/coopy/table_io'
require_relative 'lib/coopy/table_modifier'
require_relative 'lib/coopy/terminal_diff_render'
require_relative 'lib/coopy/unit'
require_relative 'lib/coopy/viterbi'
require_relative 'lib/haxe/imap'
require_relative 'lib/haxe/ds/int_map'
require_relative 'lib/haxe/ds/string_map'
require_relative 'lib/haxe/format/json_parser'
require_relative 'lib/haxe/format/json_printer'
require_relative 'lib/haxe/io/bytes'
require_relative 'lib/haxe/io/output'
require_relative 'lib/haxe/io/eof'
require_relative 'lib/haxe/io/error'
require_relative 'lib/rb/boot'
require_relative 'lib/rb/ruby_iterator'
require_relative 'lib/sys/io/file_handle'
require_relative 'lib/sys/io/hx_file'
require_relative 'lib/sys/io/file_output'


def _hx_ushr(x,ct) (((x<0) ? (x + 0x100000000) : x) >> ct) end
def _hx_str(x) (x.nil? ? 'null' : x.to_s) end
def _hx_add(x,y) (((x.is_a? String)||(y.is_a? String)) ? (_hx_str(x)+_hx_str(y)) : (x+y)) end
def _hx_ord(s) return 0 if s.nil?; s.ord end
$hx_exception_classes = {}
def hx_exception_class(c)
  $hx_exception_classes[c.name] ||= Class.new(RuntimeError) do
    Object.const_set((c.name.split(/::/)[-1]||'') + 'HaxeException',self)
    attr_accessor :hx_exception_target
    def initialize(target) @hx_exception_target = target; end
  end
end
def hx_raise(x)
  hx_exception_class(x.class).new(x)
end
def hx_rescue(x)
  hx_exception_class(x.class)
end
def hx_rescued(x)
  return x.hx_exception_target if x.respond_to? :hx_exception_target
  x
end


Daff = Coopy
if __FILE__ == $0
	Coopy::Coopy.main
end
