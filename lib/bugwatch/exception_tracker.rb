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

  class ExceptionTracker

    def initialize(repo)
      @repo = repo
    end

    def discover(begin_sha, exception_data, end_sha=nil)
      commits = @repo.commits(begin_sha)
      exception_commit = commits.first
      exception_sources = exception_data.backtrace.map {|(file, line)| exception_commit.identify(file, line.to_i) }
      commits_in_range(commits, end_sha).select do |commit|
        diffs(commit, exception_data).any? do |diff|
          exception_sources.any? {|exception_source| touched_exception?(diff.modifications, exception_source) }
        end
      end
    end

    private

    def commits_in_range(commits, end_sha)
      commits.take_while do |commit|
        commit.sha != end_sha
      end
    end

    def diffs(commit, exception_data)
      files = exception_data.backtrace.map(&:first)
      commit.diffs.select do |diff|
        files.include? diff.path
      end
    end

    def touched_exception?(modifications, exception_source)
      exception_source.any? { |klass, _methods|
        modifications[klass] && _methods.any? { |func| modifications[klass].include? func } }
    end

  end

end