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

require './test_helper'

class RubyComplexityTest < Test::Unit::TestCase

  attr_reader :flog_score, :diff1, :diff2, :sut
  def setup
    @flog_score = Bugwatch::FlogScore.new([])
    @diff1 = Bugwatch::Diff.new(path: 'file.rb')
    @diff2 = Bugwatch::Diff.new(path: 'file_spec.rb')
    @sut = Bugwatch::RubyComplexity.new([diff1, diff2])
  end

  test 'score creates flog score with ruby (non test) diffs' do
    Bugwatch::FlogScore.expects(:new).with([diff1]).returns(flog_score)
    flog_score.expects(:total_score).returns(10)
    assert_equal 10, sut.score
  end

  test 'test_score creates flog score with ruby test diffs' do
    Bugwatch::FlogScore.expects(:new).with([diff2]).returns(flog_score)
    flog_score.expects(:total_score).returns(20)
    assert_equal 20, sut.test_score
  end

  test 'scores gets scores from flog' do
    Bugwatch::FlogScore.expects(:new).with([diff1]).returns(flog_score)
    flog_score.expects(:scores).returns([['file.rb', 10, 20]])
    result = sut.scores.first
    assert_equal 'file.rb', result.file
    assert_equal 10, result.before_score
    assert_equal 20, result.after_score
  end

  test 'test_scores gets test scores from flog' do
    Bugwatch::FlogScore.expects(:new).with([diff2]).returns(flog_score)
    flog_score.expects(:scores).returns([['file_test.rb', 10, 20]])
    result = sut.test_scores.first
    assert_equal 'file_test.rb', result.file
    assert_equal 10, result.before_score
    assert_equal 20, result.after_score
  end

  test 'cyclomatic returns empty list' do
    assert_equal [], sut.cyclomatic
  end

end