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

  class Repo

    REPO_PATH = 'repos'

    attr_reader :name, :url

    def self.discover(name, url)
      new(name, url).tap {|repo| repo.discover! }
    end

    def initialize(name, url)
      @name = name
      @url = url
    end

    def discover!
      if exists?
        update!
      else
        clone!
      end
    end

    def clone!
      Kernel.system("cd #{REPO_PATH}; git clone #{url} #{name}")
    end

    def update!
      Kernel.system("cd #{path_to_repo}; git fetch origin master; git reset --hard origin/master; git fetch --tags")
    end

    def exists?
      File.exists?(path_to_repo)
    end

    def analyze!(caching_strategy, analyzers, begin_sha=nil)
      import(caching_strategy, begin_sha)
      analyze(caching_strategy, *analyzers)
    end

    def import(caching_strategy, begin_sha=nil)
      Import.new(self, caching_strategy).import(sha_or_head(begin_sha))
    end

    def analyze(caching_strategy, *analyzers)
      Analysis.new(self, caching_strategy).analyze(*analyzers)
    end

    def head
      rugged_repo.head.target
    end

    def commits(begin_sha=nil)
      rugged_repo.walk(sha_or_head(begin_sha)).map do |rugged_commit|
        self.commit(rugged_commit.oid)
      end
    end

    def commit(sha)
      grit_commit = grit.commit(sha)
      Commit.from_grit(grit_commit) if grit_commit
    end

    def commit_shas(begin_sha=nil)
      rugged_repo.walk(sha_or_head(begin_sha)).map(&:oid)
    end

    def tree
      Tree.new(grit.tree)
    end

    def grit
      @grit ||= Grit::Repo.new(path_to_repo)
    end

    def tags
      grit_tags.map do |tag|
        Tag.new(tag)
      end
    end

    private

    def sha_or_head(sha)
      sha || head
    end

    def grit_tags
      @grit_tags ||= grit.tags
    end

    def path_to_repo
      "#{REPO_PATH}/#{name}"
    end

    def rugged_repo
      @rugged_repo ||= Rugged::Repository.new(path_to_repo)
    end

  end

end