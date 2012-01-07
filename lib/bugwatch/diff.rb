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

  class Diff

    extend Attrs

    Content = Struct.new(:path, :a_blob, :b_blob)

    attrs :path
    lazy_attrs :diff, :a_blob, :b_blob

    def self.from_grit(grit_diff)
      new path: String(grit_diff.b_path || grit_diff.a_path),
          diff: -> { grit_diff.diff },
          a_blob: -> { blob_data(grit_diff.a_blob) },
          b_blob: -> { blob_data(grit_diff.b_blob) }
    end

    def initialize(attributes={})
      @attributes = attributes
    end

    def identify(line_number)
      DiffParser.new(diff, b_blob).modifications(line_number..line_number)
    end

    def modifications
      DiffParser.new(diff, b_blob).modifications
    end

    def content
      Content.new(path, a_blob, b_blob)
    end

    private

    def self.blob_data(blob)
      blob.data if blob
    end

  end

end