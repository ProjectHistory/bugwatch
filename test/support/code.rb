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

class ChangedDummyCode
  def self.blob
    %q{class Difference

    def test_method
      difference = lambda {|x, y| x - y}
      difference_by_5 = lambda {|x| difference.call(x, 5)}
    end

  end}
  end

  def self.diff
    %q{
    --- a/file1.rb
    +++ b/file1.rb
    @@ -1,7 +1,8 @@
     class Difference

       def test_method
    -    # implement this later
    +    difference = lambda {|x, y| x - y}
    +    difference_by_5 = lambda {|x| difference.call(x, 5)}
       end

     end
    }
  end
end

def added_dummy_code
  %q{class Difference

  def some_method(name)
    if name.start_with?("J")
      puts "You are awesome"
    else
      puts "thanks for trying"
    end
  end

  def get_difference_by_5
    difference = lambda {|x, y| x - y}
    difference_by_5 = lambda {|x| difference.call(x, 5)}
  end

end}
end

def class_level_dummy_code
  %q{class Difference

  attr_reader :foo

  def some_method(name)
    if name.start_with?("J")
      puts "You are awesome"
    else
      puts "thanks for trying"
    end
  end

  def get_difference_by_5
    difference = lambda {|x, y| x - y}
    difference_by_5 = lambda {|x| difference.call(x, 5)}
  end

end}
end

def small_file_dummy_code
  %q{class Test

  def addition(num1, num2)
    num1 + num2
  end

  def subtraction(num1, num2)
    num1 - num2
  end

end}
end