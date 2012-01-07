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

class MockCachingStrategy

  attr_reader :store_call_args

  def store(*args)
    @store_call_args = args
  end

  def store_analysis(commit, key)

  end

  def imported
    raise 'Stub this'
  end

  def analyzed(key)
    raise 'Stub this'
  end

end

class MockAnalyzer

  attr_reader :call_args, :call_count

  def initialize
    @call_count = 0
    @call_args = []
  end

  def call(commit)
    @call_args << commit
    @call_count += 1
  end

  def key
    'key'
  end

end

module GritFixtures

  def create_commit(additional={})
    stub('Grit::Commit', {
                         :sha => 'XXX', :short_message => 'fixed bug', :tree => stub('Grit::Tree'),
                         :author => stub('Grit::Actor', name: 'foo', email: 'testing@example.com'),
                         :committer => stub('Grit::Actor', name: 'bar', email: 'bar@example.com'),
                         :committed_date => DateTime.new(2010, 10, 10),
                         :authored_date => DateTime.new(2011, 10, 10),
                         :stats => stub('Grit::Stats', files: [['file.rb', 1, 2, 3]]),
                         :diffs => [create_diff],
    }.merge(additional))
  end

  def create_diff(file='file.rb', additionals={})
    stub('Grit::Diff', {
                        a_blob: stub('Grit::Blob', data: 'a_blob data'),
                        b_blob: stub('Grit::Blob', data: ChangedDummyCode.blob),
                        a_path: file, b_path: file, diff: ChangedDummyCode.diff
    }.merge(additionals))
  end

end