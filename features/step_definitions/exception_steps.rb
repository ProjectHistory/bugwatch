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

When /^I get the following exception:$/ do |table|
  exception_type = table.hashes.first['type']
  backtrace = table.hashes.map {|data| [data['file'], data['line'].to_i] }
  @exception = Bugwatch::ExceptionData.new(:type => exception_type, :backtrace => backtrace)
end

def create_grit_commit(sha, filename, blob, diff_text)
  diff = Bugwatch::Diff.new(path: filename, diff: diff_text, b_blob: blob.data)
  tree = Bugwatch::Tree.new
  tree.stubs('/').with(filename).returns(blob)
  tree.stubs('/').with{|(arg, _)| arg != filename }.returns(nil)
  Bugwatch::Commit.new(sha: sha, diffs: [diff], tree: tree)
end

Given /^I have a simple commit "([^"]*)" modifying "([^"]*)"$/ do |sha, filename|
  b_blob_data = '
class Test

  def something
    # filler content
    # modifying some content
    # filler content
  end

end
  '
  diff_text = %Q{
--- a/#{filename}
+++ b/#{filename}
@@ -2,7 +2,7 @@

   def something
     # filler content
-    # filler content
+    # modifying some content
     # filler content
   end

  }
  blob = stub('Grit::Blob', :data => b_blob_data)
  commit = create_grit_commit(sha, filename, blob, diff_text)
  @commits << commit
end

When /^the last deploy revision is "([^"]*)"$/ do |sha|
  @deploy_revision = sha
end

Then /^the liable commits should be:$/ do |table|
  result = Bugwatch::ExceptionTracker.new(@repo).discover(@deploy_revision, @exception, @deploy_before_last_revision).map(&:sha)
  assert_equal table.hashes.map{|data| data['sha']}, result
end

Given /^I am analyzing "([^"]*)"$/ do |repo_name|
  @repo = Bugwatch::Repo.new(repo_name, 'url')
  @commits = []
  @repo.stubs(:commits).with(@deploy_revision).returns(@commits)
end

Given /^the deploy revision before last is "([^"]*)"$/ do |sha|
  @deploy_before_last_revision = sha
end