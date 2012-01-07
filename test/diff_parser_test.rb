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

class DiffParserTest < Test::Unit::TestCase

  test '#modifications returns classes and functions' do
    sut = Bugwatch::DiffParser.new(ChangedDummyCode.diff, ChangedDummyCode.blob)
    expected = {'Difference' => ['test_method']}
    assert_equal expected, sut.modifications
  end

  test 'method name changed and method added' do
    diff_text = %q{
--- a/file1.rb
+++ b/file1.rb
@@ -1,7 +1,16 @@
 class Difference

-  def test_method
-    # implement this later
+  def some_method(name)
+    if name.start_with?("J")
+      puts "You are awesome"
+    else
+      puts "thanks for trying"
+    end
+  end
+
+  def get_difference_by_5
+    difference = lambda {|x, y| x - y}
+    difference_by_5 = lambda {|x| difference.call(x, 5)}
   end

 end
  }
    expected = {'Difference' => ['some_method', 'get_difference_by_5']}
    sut = Bugwatch::DiffParser.new(diff_text, added_dummy_code)
    assert_equal expected, sut.modifications
  end

  test 'uses nil as method name if change not within method' do
    diff_text = %q{
--- a/difference.rb
+++ b/difference.rb
@@ -1,5 +1,7 @@
 class Difference

+  attr_reader :foo
+
   def some_method(name)
     if name.start_with?("J")
       puts "You are awesome"
    }
    expected = {'Difference' => [nil]}
    sut = Bugwatch::DiffParser.new(diff_text, class_level_dummy_code)
    assert_equal expected, sut.modifications
  end

  test 'short file' do
    diff_text = %q{
--- a/file.rb
+++ b/file.rb
@@ -5,7 +5,7 @@ class Test
   end

   def subtraction(num1, num2)
-    num1 - num1
+    num1 - num2
   end

 end
    }
    expected = {'Test' => ['subtraction']}
    sut = Bugwatch::DiffParser.new(diff_text, small_file_dummy_code)
    assert_equal expected, sut.modifications
  end

end