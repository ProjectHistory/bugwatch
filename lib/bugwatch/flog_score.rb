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

require File.expand_path('./../../../vendor/flog/lib/flog', __FILE__)

module Bugwatch

  class FlogScore

    include RubyFileAdapter

    def initialize(diff_contents)
      @diff_contents = diff_contents
    end

    def scores
      filtered_diff_contents.map do |diff_content|
        [diff_content.path, score_blob(diff_content.a_blob), score_blob(diff_content.b_blob)]
      end
    end

    def average
      average_score = scores.reduce(0.0) do |memo, score|
        _, before_score, after_score = score
        (after_score - before_score) + memo
      end / scores.size.to_f
      average_score.nan? ? 0.0 : average_score
    end

    def total_score
      scores.reduce(0) do |calculated_score, (_, before_score, after_score)|
        calculated_score + (after_score - before_score)
      end
    end

    private

    def filtered_diff_contents
      @diff_contents.select(&:path)
    end

    def score_blob(blob)
      blob ? score(blob) : 0.0
    end

    def score(code)
      flog.flog_code(code)
      flog.total
    rescue
      0.0
    ensure
      flog.reset
    end

    def flog
      @flog ||= Flog.new parser: RubyParser
    end

  end

end