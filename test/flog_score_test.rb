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

class FlogScoreTest < Test::Unit::TestCase

  attr_reader :a_blob, :b_blob

  def setup
    @a_blob = 'class Test; end'
    @b_blob = 'class Test < Object; end'
  end

  def create_diff(file, a_blob, b_blob)
    Bugwatch::Diff.new(path: file, a_blob: a_blob, b_blob: b_blob)
  end

  test 'scores returns [file_name old_score new_score]' do
    diff = create_diff('file.rb', a_blob, b_blob)
    sut = Bugwatch::FlogScore.new([diff])
    sut.expects(:score).with(a_blob).returns(0.0)
    sut.expects(:score).with(b_blob).returns(1.0)
    assert_equal [['file.rb', 0.0, 1.0]], sut.scores
  end

  test 'scores sets defaults for new files' do
    diff = create_diff('file.rb', nil, b_blob)
    sut = Bugwatch::FlogScore.new([diff])
    sut.expects(:score).with(nil).never
    sut.expects(:score).with(b_blob).returns(1.0)
    assert_equal [['file.rb', 0.0, 1.0]], sut.scores
  end

  def setup_scores
    c_blob, d_blob = 'test', 'test2'
    diff1 = create_diff('file.rb', a_blob, b_blob)
    diff2 = create_diff('file2.rb', c_blob, d_blob)
    sut = Bugwatch::FlogScore.new([diff1, diff2])
    sut.stubs(:score).with(a_blob).returns(1.0)
    sut.stubs(:score).with(b_blob).returns(2.0)
    sut.stubs(:score).with(c_blob).returns(5.0)
    sut.stubs(:score).with(d_blob).returns(10.0)
    sut
  end

  test 'average' do
    sut = setup_scores()
    assert_equal 3.0, sut.average
  end

  test 'total_score' do
    sut = setup_scores()
    assert_equal 6.0, sut.total_score
  end

  test 'scores sets defaults for deleted files' do
    diff = create_diff('file.rb', a_blob, nil)
    sut = Bugwatch::FlogScore.new([diff])
    sut.expects(:score).with(a_blob).returns(1.0)
    sut.expects(:score).with(nil).never
    assert_equal [['file.rb', 1.0, 0.0]], sut.scores
  end

  test 'skips scoring files with no name' do
    diff = create_diff(nil, a_blob, b_blob)
    sut = Bugwatch::FlogScore.new([diff])
    assert_equal [], sut.scores
  end

  test 'scores parse errors as 0' do
    diff = create_diff('file.rb', a_blob, b_blob)
    sut = Bugwatch::FlogScore.new([diff])
    flog = Flog.new
    sut.stubs(:flog).returns(flog)
    flog.expects(:flog_code).with(a_blob).raises(Racc::ParseError)
    flog.expects(:flog_code).with(b_blob).raises(RubyParser::SyntaxError)
    assert_equal [['file.rb', 0.0, 0.0]], sut.scores
  end

end