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
require 'support/fixtures'

class CommitTests < Test::Unit::TestCase

  include GritFixtures

  attr_reader :sut, :grit_commit

  def setup
    @grit_commit = create_commit
    @sut = Bugwatch::Commit.from_grit(grit_commit)
  end

  test 'from_grit creates commit with sha' do
    assert_equal grit_commit.sha, sut.sha
  end

  test 'from_grit creates commit with message' do
    assert_equal grit_commit.short_message, sut.message
  end

  test 'from_grit creates commit with author name and email' do
    assert_equal grit_commit.author.name, sut.author_name
    assert_equal grit_commit.author.email, sut.author_email
  end

  test 'from_grit creates commit with committer name and email' do
    assert_equal grit_commit.committer.name, sut.committer_name
    assert_equal grit_commit.committer.email, sut.committer_email
  end

  test 'from_grit creates commit with committed date' do
    assert_equal grit_commit.committed_date, sut.committed_date
  end

  test 'from_grit creates commit with authored date' do
    assert_equal grit_commit.authored_date, sut.authored_date
  end

  test 'from_grit creates commit with stats' do
    result = sut.stats.first
    assert_not_nil result
    assert_equal 'file.rb', result.file
    assert_equal 1, result.additions
    assert_equal 2, result.deletions
    assert_equal 3, result.total
  end

  test 'from_grit creates commit with diffs' do
    grit_diff = grit_commit.diffs.first
    result = sut.diffs.first
    assert_not_nil result
    assert_equal 'file.rb', result.content.path
    assert_equal grit_diff.a_blob.data, result.content.a_blob
    assert_equal grit_diff.b_blob.data, result.content.b_blob
  end

  test 'identify returns hash of class and methods at file and line number' do
    blob = stub('Grit::Blob', :data => 'blob data')
    sut.tree.expects('/').with('file.rb').returns(blob)
    expected = {'Test' => ['method_name']}
    Bugwatch::MethodParser.expects(:find).with(blob.data, (5..5)).returns(expected)
    assert_equal expected, sut.identify('file.rb', 5)
  end

  test 'identify returns empty hash if file not exists in tree' do
    sut.tree.expects('/').with('file.rb').returns(nil)
    assert_equal Hash.new, sut.identify('file.rb', 5)
  end

  test 'complexity creates complexity adapter for lang with diff contents' do
    complexity = Bugwatch::RubyComplexity.new(sut.diffs)
    Bugwatch::RubyComplexity.expects(:new).with(sut.diffs).returns(complexity)
    assert_equal complexity, sut.complexity(:ruby)
  end

  test 'complexity returns nil if no adapter for lang' do
    Bugwatch.stubs(:adapters).returns({})
    assert_nil sut.complexity(:ruby)
  end

  test 'complexity returns nil if no complexity adapter for lang' do
    Bugwatch.stubs(:adapters).returns({ruby: Bugwatch::Adapter.new(Bugwatch::RubyFileAdapter, nil)})
    assert_nil sut.complexity(:ruby)
  end

  test 'churn creates churn adapter with commit stats' do
    commit_stats = [Bugwatch::Commit::Stats.new('file.rb', 10, 10, 20)]
    sut.expects(:stats).returns(commit_stats)
    churn = Bugwatch::Churn.new(commit_stats, Bugwatch::RubyFileAdapter)
    Bugwatch::Churn.expects(:new).with(commit_stats, Bugwatch::RubyFileAdapter).returns(churn)
    assert_equal churn, sut.churn(:ruby)
  end

  test 'churn returns nil if no adapter for lang' do
    assert_nil sut.churn(:js)
  end

  test 'uses new adapters as they become available' do
    sut.stubs(:stats)
    Bugwatch.add_adapter(:js, Object)
    assert_not_nil sut.churn(:js)
  end

end