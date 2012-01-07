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

Gem::Specification.new do |s|
  s.name = 'bugwatch'
  s.version = '0.1'
  s.date = '2012-02-13'

  s.summary = 'bugwatch'
  s.description = 'SCM history mining and code analysis platform'

  s.authors = ['Jacob Richardson']
  s.email = 'jacobr@groupon.com'

  s.require_paths = %w[lib]

  s.add_dependency('grit', '2.5.0')
  s.add_dependency('ruby_parser', '~> 3.0.1')
  s.add_dependency('rugged', '0.16.2')

  # = MANIFEST =
  s.files = %w[
    bugwatch.gemspec
    lib/bugwatch.rb
    lib/bugwatch/adapters.rb
    lib/bugwatch/analysis.rb
    lib/bugwatch/attrs.rb
    lib/bugwatch/churn.rb
    lib/bugwatch/commit.rb
    lib/bugwatch/complexity_score.rb
    lib/bugwatch/diff.rb
    lib/bugwatch/diff_parser.rb
    lib/bugwatch/exception_data.rb
    lib/bugwatch/exception_tracker.rb
    lib/bugwatch/file_adapters/ruby_file_adapter.rb
    lib/bugwatch/flog_score.rb
    lib/bugwatch/import.rb
    lib/bugwatch/method_parser.rb
    lib/bugwatch/repo.rb
    lib/bugwatch/ruby_complexity.rb
    lib/bugwatch/tag.rb
    lib/bugwatch/tree.rb
    vendor/flog/lib/flog.rb
  ]
  # = MANIFEST =

end
