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

module Bugwatch

  class RubyComplexity

    include RubyFileAdapter

    def initialize(diffs)
      @diffs = diffs
    end

    def score
      ruby_flog.total_score
    end

    def test_score
      test_flog.total_score
    end

    def scores
      complexity_scores(ruby_flog.scores)
    end

    def test_scores
      complexity_scores(test_flog.scores)
    end

    def cyclomatic
      []
    end

    private

    def ruby_flog
      FlogScore.new(ruby_diffs)
    end

    def test_flog
      FlogScore.new(test_diffs)
    end

    def ruby_diffs
      @diffs.select {|diff| analyzable_file? diff.path }
    end

    def test_diffs
      @diffs.select {|diff| test_file? diff.path }
    end

    def complexity_scores(scores)
      scores.map {|(file, before_score, after_score)| ComplexityScore.new(file, before_score, after_score) }
    end

  end

end