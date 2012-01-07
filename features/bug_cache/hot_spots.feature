Feature:
  As a developer
  I want to know the areas of the code
  with the highest bug density

  Background:
    Given the bug cache allocation is 10%
    And there are 30 files in the system
    And I have the following bug reports:
      | file     | line_number | exception     |
      | file1.rb | 5           | NoMethodError |
      | file2.rb | 2           | ValueError    |
      | file3.rb | 8           | Exception     |

  Scenario: Identify hot spots with highest bug density
    Then the hot files should be:
      | file     |
      | file3.rb |
      | file2.rb |
      | file1.rb |

  Scenario: Expire bugs from cache when least used and need more room
    When I add the following bug to the cache:
      | file     | line_number | exception |
      | file4.rb | 4           | Exception |
    Then the hot files should be:
      | file     |
      | file4.rb |
      | file3.rb |
      | file2.rb |
