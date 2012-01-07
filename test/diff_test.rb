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
require 'support/code'

class DiffTests < Test::Unit::TestCase

  include GritFixtures

  attr_reader :filename, :grit_diff, :diff_parser, :sut

  def setup
    @filename = 'file1.rb'
    @grit_diff = create_diff(filename)
    @diff_parser = Bugwatch::DiffParser.new('diff', 'data')
    @sut = Bugwatch::Diff.new(diff: 'diff', b_blob: 'data')
    Bugwatch::DiffParser.stubs(:new).with('diff', 'data').returns(diff_parser)
  end

  test 'from_grit includes path' do
    sut = Bugwatch::Diff.from_grit(grit_diff)
    assert_equal filename, sut.path
  end

  test 'from_grit includes a_blob' do
    sut = Bugwatch::Diff.from_grit(grit_diff)
    assert_not_nil sut.a_blob
    assert_equal grit_diff.a_blob.data, sut.a_blob
  end

  test 'from_grit includes b_blob' do
    sut = Bugwatch::Diff.from_grit(grit_diff)
    assert_not_nil sut.b_blob
    assert_equal grit_diff.b_blob.data, sut.b_blob
  end

  test 'from_grit a_blob returns nil if no a blob' do
    sut = Bugwatch::Diff.from_grit(create_diff(filename, a_blob: nil))
    assert_nil sut.a_blob
  end

  test 'from_grit b_blob returns nil if no b blob' do
    sut = Bugwatch::Diff.from_grit(create_diff(filename, b_blob: nil))
    assert_nil sut.b_blob
  end

  test 'from_grit includes diff' do
    sut = Bugwatch::Diff.from_grit(grit_diff)
    assert_equal grit_diff.diff, sut.diff
  end

  test 'modifications gets modifications from diff parser' do
    expected = {'foo' => ['bar']}
    diff_parser.expects(:modifications).returns(expected)
    assert_equal expected, sut.modifications
  end

  test 'identify gets modifications using explicit line number from diff parser' do
    expected = {'foo' => ['bar']}
    diff_parser.expects(:modifications).with(5..5).returns(expected)
    assert_equal expected, sut.identify(5)
  end

end