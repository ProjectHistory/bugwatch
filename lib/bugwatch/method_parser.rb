# Copyright (c) 2013, Groupon, Inc.
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 
# Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
# 
# Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
# 
# Neither the name of GROUPON nor the names of its contributors may be
# used to endorse or promote products derived from this software without
# specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'ruby_parser'
require 'sexp_processor'

module Bugwatch

  class MethodParser < SexpProcessor

    attr_reader :parser, :klasses

    def initialize(line_range)
      super()
      @line_range = line_range
      @klasses = Hash.new {|h, k| h[k] = []}
      @current_class = []
      self.auto_shift_type = true
    end

    def self.find(code, line_range)
      method_parser = new(line_range)
      ast = RubyParser.new.process(code)
      method_parser.process ast
      method_parser.klasses
    end

    def process_class(exp)
      begin_line = exp.line
      line_range = begin_line..exp.last.line # TODO figure out last line
      class_name = get_class_name(exp.shift)
      within_class(class_name, line_range) do
        process(exp.shift) until exp.empty?
      end
      s()
    end

    alias_method :process_module, :process_class

    def process_defn(exp)
      first_line_of_method = exp.line
      name = exp.shift
      @klasses[current_class].push name.to_s if within_target?(first_line_of_method..exp.last.line)
      process(exp.shift) until exp.empty?
      s()
    end

    def within_class(class_name, line_range, &block)
      @current_class.push class_name
      methods_before_process = @klasses[current_class].count
      block.call
      if (methods_before_process == @klasses[current_class].count) && within_target?(line_range)
        @klasses[current_class].push nil
      end
      @current_class.shift
    end

    def within_target?(range)
      @line_range.any? {|num| range.cover? num}
    end

    def current_class
      @current_class.join('::')
    end

    def get_class_name(exp, namespace=[])
      if exp.is_a?(Sexp) && exp.first.is_a?(Sexp)
        get_class_name(exp.first, namespace + [exp.last])
      elsif exp.is_a?(Sexp) && exp[1].is_a?(Sexp)
        get_class_name(exp[1], namespace + [exp.last])
      else
        ([Array(exp).last] + namespace.reverse).join('::')
      end
    end

  end

end
