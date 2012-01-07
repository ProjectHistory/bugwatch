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

class ExceptionTrackerTest < Test::Unit::TestCase

  attr_reader :sut, :exception_data, :exception_commit, :wrong_commit, :repo

  def diff(filename, diff_contents)
    Bugwatch::Diff.new(path: filename).tap do |diff|
      diff.stubs(:modifications).returns(diff_contents)
    end
  end

  def commit(diffs, sha)
    Bugwatch::Commit.new(diffs: diffs, sha: sha, tree: Bugwatch::Tree.new)
  end

  def setup
    @repo = Bugwatch::Repo.new('repo_name', 'repo_url')
    @sut = Bugwatch::ExceptionTracker.new(repo)
    @exception_data = Bugwatch::ExceptionData.new(:type => 'NoMethodError', :backtrace => [['file.rb', '5']])
    @exception_commit = commit([diff('file.rb', {'Test' => ['test', 'some_function']})], 'AAA')
    @exception_commit.stubs(:identify).with('file.rb', 5).returns({'Test' => ['some_function']})
    @wrong_commit = commit([diff('file.rb', {'SomeClass' => ['test', 'some_function']})], 'ZZZ')
    @begin_sha = 'AAA'
  end

  test 'discover tracks back commits and selects a liable commit' do
    repo.expects(:commits).with(@begin_sha).returns([exception_commit, wrong_commit])
    result = sut.discover(@begin_sha, exception_data)
    assert_equal [exception_commit], result
  end

  test 'discover ignores commits not touching exception source' do
    repo.expects(:commits).with(@begin_sha).returns([wrong_commit])
    result = sut.discover(@begin_sha, exception_data)
    assert_equal [], result
  end

  test 'discover selects commits that modify a method in backtrace' do
    exception = Bugwatch::ExceptionData.new(:type => 'NoMethodError',
                          :backtrace => [['file2.rb', 5], ['file3.rb', 1], [exception_data.file, exception_data.line]])
    exception_commit.expects(:identify).with('file2.rb', 5).returns({'Test' => ['some_function']})
    exception_commit.expects(:identify).with('file3.rb', 1).returns({'Test' => ['some_function']})
    repo.expects(:commits).with(@begin_sha).returns([exception_commit, wrong_commit])
    result = sut.discover(@begin_sha, exception)
    assert_equal [exception_commit], result
  end

  test 'discover rejects commits beyond end sha if specified' do
    repo.expects(:commits).with(@begin_sha).returns([exception_commit, wrong_commit, exception_commit])
    result = sut.discover(@begin_sha, exception_data, wrong_commit.sha)
    assert_equal [exception_commit], result
  end

end