def bug_fix(table)
  table.hashes.map(&:values).map do |(file, date, sha)|
    BugFix.new(file, date || Time.now.to_s, sha)
  end
end

def fix_cache
  @fix_cache ||= FixCache.new(@fix_cache_file_count || 30, @fix_cache_limit)
end

Given /^I have the following bug fixes:$/ do |table|
  @bug_fixes = bug_fix(table)
  fix_cache.add(*@bug_fixes)
end

Then /^the bug fix hot files should be:$/ do |table|
  assert_equal(table.rows.flatten.sort, fix_cache.hot_files.sort)
end

Given /^the fix cache allocation is (\d+)%$/ do |percent|
  @fix_cache_limit = percent.to_i
end

When /^there are (\d+) files in the project$/ do |file_count|
  @fix_cache_file_count = file_count.to_i
end

When /^I add the following fixes to the cache:$/ do |table|
  fixes = bug_fix(table)
  fix_cache.add(*fixes)
end