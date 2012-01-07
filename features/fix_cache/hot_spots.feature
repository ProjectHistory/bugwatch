Feature:
  As a developer
  I want to know the areas of the code
  with the highest bug density

  Background:
    Given the fix cache allocation is 10%
    And there are 30 files in the project

  Scenario: Identify hot spots
    Given I have the following bug fixes:
      | file     |
      | file1.rb |
      | file2.rb |
      | file3.rb |
    Then the bug fix hot files should be:
      | file     |
      | file1.rb |
      | file2.rb |
      | file3.rb |

  Scenario: Expire oldest bugs from cache
    Given I have the following bug fixes:
      | file     | date       |
      | file1.rb | 10-10-2010 |
      | file2.rb | 11-10-2010 |
      | file3.rb | 12-10-2010 |
    When I add the following fixes to the cache:
      | file     | date       |
      | file4.rb | 13-10-2010 |
    Then the bug fix hot files should be:
      | file     |
      | file2.rb |
      | file3.rb |
      | file4.rb |

  Scenario: Expire least used bug from cache
    Given I have the following bug fixes:
      | file     |
      | file1.rb |
      | file1.rb |
      | file2.rb |
      | file3.rb |
      | file3.rb |
    When I add the following fixes to the cache:
      | file     |
      | file4.rb |
      | file4.rb |
    Then the bug fix hot files should be:
      | file     |
      | file1.rb |
      | file3.rb |
      | file4.rb |

