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

  class Commit

    include RubyFileAdapter
    extend Attrs

    Stats = Struct.new(:file, :additions, :deletions, :total)

    def self.from_grit(grit)
      author = grit.author
      committer = grit.committer
      stats = Enumerator.new {|y| grit.stats.files.each {|data| y << Stats.new(*data) } }
      diffs = Enumerator.new {|y| grit.diffs.each {|diff| y << Diff.from_grit(diff) } }
      tree = Tree.new(grit.tree)
      new sha: grit.sha, message: grit.short_message, diffs: diffs, stats: stats, tree: tree,
          author_name: author.name, author_email: author.email, authored_date: grit.authored_date,
          committer_name: committer.name, committer_email: committer.email, committed_date: grit.committed_date
    end

    def initialize(attributes={})
      @attributes = attributes
    end

    attrs :sha, :message, :diffs, :stats
    attrs :author_name, :author_email, :authored_date
    attrs :committer_name, :committer_email, :committed_date
    lazy_attrs :tree

    def files
      @files ||= stats.map(&:file)
    end

    def complexity(lang=:ruby)
      adapter = Bugwatch.adapters[lang]
      adapter.complexity.new(diffs) if adapter && adapter.complexity
    end

    def churn(lang=:ruby)
      adapter = Bugwatch.adapters[lang]
      Churn.new(stats, adapter.file) if adapter
    end

    # TODO don't use grit blob
    def identify(filename, line_number)
      blob = tree / filename
      blob ? MethodParser.find(blob.data, line_number..line_number) : {}
    end

  end

end