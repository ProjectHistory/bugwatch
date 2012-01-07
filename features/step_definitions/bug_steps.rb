def bug_report(table)
  table.hashes.map(&:values).map do |(file, line_number, exception)|
    Bug.new(file, line_number, exception)
  end
end

def bug_cache
  @bug_cache ||= BugCache.new()
end

Given /^I have the following bug reports:$/ do |table|
  @bug_reports = bug_report(table)
  @bug_reports.each {|bug| bug_cache.add(bug)}
end

Then /^the hot files should be:$/ do |table|
  assert_equal(table.rows.flatten, bug_cache.hot_files)
end

Given /^the bug cache allocation is (\d+)%$/ do |percent|
  bug_cache.limit = percent.to_i
end
Given /^there are (\d+) files in the system$/ do |file_count|
  bug_cache.files = file_count.to_i
end
When /^I add the following bug to the cache:$/ do |table|
  bug_cache.add(bug_report(table).first)
end