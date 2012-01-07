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

class AnalysisTest < Test::Unit::TestCase

  attr_reader :sut, :caching_strategy, :repo, :commit, :analyzer

  def setup
    @caching_strategy = MockCachingStrategy.new
    @repo = Bugwatch::Repo.new('repo_name', 'repo_url')
    @commit = Bugwatch::Commit.new(sha: 'SHA')
    @sut = Bugwatch::Analysis.new(repo, caching_strategy)
    @analyzer = MockAnalyzer.new
  end

  test 'calls analyzers for each un-analyzed commit' do
    repo.expects(:commit).with(commit.sha).returns(commit)
    caching_strategy.expects(:imported).returns([commit.sha])
    caching_strategy.expects(:analyzed).with('key').returns([])
    sut.analyze(analyzer)
    assert_equal [commit], analyzer.call_args
  end

  test 'calls caching strategy store_analysis for each un-analyzed commit' do
    repo.expects(:commit).with(commit.sha).returns(commit)
    caching_strategy.expects(:imported).returns([commit.sha])
    caching_strategy.expects(:analyzed).with('key').returns([])
    caching_strategy.expects(:store_analysis).with(commit, analyzer.key)
    sut.analyze(analyzer)
  end

  test 'skips already analyzed commits' do
    repo.expects(:commit).with(commit.sha).never
    caching_strategy.expects(:imported).returns([commit.sha])
    caching_strategy.expects(:analyzed).with(analyzer.key).returns([commit.sha])
    sut.analyze(analyzer)
    assert_equal [], analyzer.call_args
  end

end