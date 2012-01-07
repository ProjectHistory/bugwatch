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

class RepoTest < Test::Unit::TestCase

  include GritFixtures

  REPO_NAME = 'test'
  REPO_URL = 'url'

  def path_to_repo
    "#{Bugwatch::Repo::REPO_PATH}/#{REPO_NAME}"
  end

  def clone_command
    "cd repos; git clone #{REPO_URL} #{REPO_NAME}"
  end

  def update_command
    "cd #{path_to_repo}; git fetch origin master; git reset --hard origin/master; git fetch --tags"
  end

  attr_reader :sut, :grit, :rugged_repo, :sha, :grit_commit, :rugged_commit

  def setup
    @sut = Bugwatch::Repo.new(REPO_NAME, REPO_URL)
    @grit = stub('Grit::Repo')
    @sha = 'SHA'
    @rugged_repo = stub('Rugged::Repository')
    @grit_commit = create_commit(sha: sha)
    @rugged_commit = stub('Rugged::Commit', oid: sha)
    rugged_repo.stubs(:head).returns(stub(target: 'head_sha'))
    Kernel.stubs(:system)
    Grit::Repo.stubs(:new).with(path_to_repo).returns(grit)
    Rugged::Repository.stubs(:new).with(path_to_repo).returns(rugged_repo)
  end

  test '#commit returns commit with grit' do
    grit.expects(:commit).with(grit_commit.sha).returns(grit_commit)
    result = sut.commit(grit_commit.sha)
    assert_equal grit_commit.sha, result.sha
  end

  test '#commit returns nil if no grit commit exists' do
    grit.expects(:commit).with(grit_commit.sha).returns(nil)
    assert_nil sut.commit(grit_commit.sha)
  end

  test 'tree gets tree from repo' do
    tree = stub('Grit::Tree')
    grit.expects(:tree).returns(tree)
    bugwatch_tree = Bugwatch::Tree.new
    Bugwatch::Tree.expects(:new).with(tree).returns(bugwatch_tree)
    assert_equal bugwatch_tree, sut.tree
  end

  test '#discover! clones repo if it doesnt exist' do
    File.expects(:exists?).with(path_to_repo).returns(false)
    Kernel.expects(:system).with(clone_command)
    sut.discover!
  end

  test '#discover! does not clone repo if exists' do
    File.expects(:exists?).with(path_to_repo).returns(true)
    Kernel.expects(:system).with(clone_command).never
    sut.discover!
  end

  test '#discover! does not update repo if doesnt exist' do
    File.expects(:exists?).with(path_to_repo).returns(false)
    Kernel.expects(:system).with(update_command).never
    sut.discover!
  end

  test '#discover! updates repo if exists' do
    File.expects(:exists?).with(path_to_repo).returns(true)
    Kernel.expects(:system).with(update_command)
    sut.discover!
  end

  test '.discover returns repo instance and calls discover!' do
    repo = Bugwatch::Repo.new(REPO_NAME, REPO_URL)
    Bugwatch::Repo.expects(:new).with(REPO_NAME, REPO_URL).returns(repo)
    repo.expects(:discover!)
    assert_equal repo, Bugwatch::Repo.discover(REPO_NAME, REPO_URL)
  end

  test 'tags returns bugwatch tags from grit' do
    bugwatch_tag = Bugwatch::Tag.new(stub('Grit::Tag'))
    grit_tag = stub('Grit::Tag')
    grit.expects(:tags).returns([grit_tag])
    Grit::Repo.expects(:new).with(path_to_repo).returns(grit)
    Bugwatch::Tag.expects(:new).with(grit_tag).returns(bugwatch_tag)
    assert_equal [bugwatch_tag], sut.tags
  end

  test 'commits retrieves commits starting from sha' do
    rugged_repo.expects(:walk).with(sha).returns([rugged_commit])
    grit.expects(:commit).with(rugged_commit.oid).returns(grit_commit)
    commits = sut.commits(sha)
    assert_not_empty commits
    result = commits.first
    assert_equal grit_commit.sha, result.sha
  end

  test 'commit_shas returns list of commit shas' do
    rugged_repo.expects(:walk).with(sha).returns([rugged_commit])
    assert_equal [rugged_commit.oid], sut.commit_shas(sha)
  end

  test 'import calls importer with caching stategy and begin sha' do
    caching_strategy = MockCachingStrategy.new
    importer = Bugwatch::Import.new(sut, caching_strategy)
    Bugwatch::Import.expects(:new).with(sut, caching_strategy).returns(importer)
    importer.expects(:import).with('sha')
    sut.import(caching_strategy, 'sha')
  end

  test 'import defaults begin sha to head' do
    caching_strategy = MockCachingStrategy.new
    importer = Bugwatch::Import.new(sut, caching_strategy)
    Bugwatch::Import.expects(:new).with(sut, caching_strategy).returns(importer)
    importer.expects(:import).with('head_sha')
    sut.import(caching_strategy)
  end

  test 'analyze calls analysis pipeline with caching strategy and analyzers' do
    analyzer = MockAnalyzer.new
    caching_strategy = MockCachingStrategy.new
    analysis = Bugwatch::Analysis.new(sut, caching_strategy)
    Bugwatch::Analysis.expects(:new).with(sut, caching_strategy).returns(analysis)
    analysis.expects(:analyze).with(analyzer)
    sut.analyze(caching_strategy, analyzer)
  end

end