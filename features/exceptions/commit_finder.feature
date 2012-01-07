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

Feature: As a developer
  I want to match exceptions with liable commits

  Background:
    Given the last deploy revision is "AAA"
    And I am analyzing "bugwatch"

  Scenario: Commit matches exception
    Given I have a simple commit "AAA" modifying "file.rb"
    When I get the following exception:
      | type          | file    | line |
      | NoMethodError | file.rb | 5    |
    Then the liable commits should be:
      | sha |
      | AAA |

  Scenario: Commit matches exception backtrace
    Given I have a simple commit "AAA" modifying "file.rb"
    When I get the following exception:
      | type          | file     | line |
      | NoMethodError | file2.rb | 5    |
      |               | file3.rb | 5    |
      |               | file4.rb | 5    |
      |               | file.rb  | 5    |
    Then the liable commits should be:
      | sha |
      | AAA |

  Scenario: Matches only commits since last deploy
    Given the deploy revision before last is "DDD"
    And I have a simple commit "AAA" modifying "file.rb"
    And I have a simple commit "BBB" modifying "file2.rb"
    And I have a simple commit "CCC" modifying "file.rb"
    And I have a simple commit "DDD" modifying "file.rb"
    And I have a simple commit "EEE" modifying "file.rb"
    When I get the following exception:
      | type          | file    | line |
      | NoMethodError | file.rb | 5    |
    Then the liable commits should be:
      | sha |
      | AAA |
      | CCC |