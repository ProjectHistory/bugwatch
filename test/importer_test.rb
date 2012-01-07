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

require File.expand_path('./../test_helper', __FILE__)
require 'support/fixtures'

class ImporterTest < Test::Unit::TestCase

  attr_reader :sha, :caching_strategy, :repo, :commit, :sut

  def setup
    @sha = 'xxx'
    @caching_strategy = MockCachingStrategy.new
    @repo = Bugwatch::Repo.new('repo_name', 'repo_url')
    @commit = Bugwatch::Commit.new(sha: sha)
    @sut = Bugwatch::Import.new(repo, caching_strategy)

  end

  test 'calls caching_strategy store for un-imported commits' do
    repo.expects(:commit).with(sha).returns(commit)
    repo.stubs(:commit_shas).with(sha).returns([sha])
    caching_strategy.stubs(:imported).returns([])
    sut.import(sha)
    assert_equal [commit], caching_strategy.store_call_args
  end

  test 'does not store already imported commits' do
    repo.stubs(:commit_shas).with(sha).returns([sha])
    caching_strategy.stubs(:imported).returns([sha])
    caching_strategy.expects(:store).never
    sut.import(sha)
  end

end