require_relative 'test_helper'
require 'bug'
require 'fix_cache'

class FixCacheTests < Test::Unit::TestCase

  def sut
    @sut ||= FixCache.new(30, 10)
  end

  def sample_bug_fix(filename='file1.rb')
    BugFix.new(filename, '10-10-2010', 'XXX')
  end

  def test_add_adds_bug_fix_to_cache
    sut.add(BugFix.new('file1.rb', '10-10-2010', 'XXX'))
    assert_include(sut.cache.keys, 'file1.rb')
  end

  def test_hot_files_returns_list_of_files_from_cache
    sut.add(sample_bug_fix)
    assert_equal(['file1.rb'], sut.hot_files)
  end

  def test_cache_limit_is_file_count_divided_by_limit
    assert_equal(3, sut.cache_limit)
  end

  def test_hot_files_cuts_off_at_cache_limit_size
    sut.add(sample_bug_fix, sample_bug_fix('file2.rb'), sample_bug_fix('file3.rb'))
    sut.add(sample_bug_fix('file4.rb'))
    assert_equal(sut.cache_limit, sut.hot_files.count)
  end

  def test_hot_files_removes_least_used_file_if_needs_room
    sut.add(sample_bug_fix, sample_bug_fix)
    sut.add(sample_bug_fix('file2.rb'))
    sut.add(sample_bug_fix('file3.rb'), sample_bug_fix('file3.rb'))
    sut.add(sample_bug_fix('file4.rb'), sample_bug_fix('file4.rb'))
    assert_equal(%w(file1.rb file3.rb file4.rb).sort, sut.hot_files.sort)
  end

  def test_hot_files_removes_file_with_oldest_bugs_if_over_limit
    sut.add(BugFix.new('file1.rb', '10-10-2010', nil))
    sut.add(BugFix.new('file2.rb', '11-10-2010', nil))
    sut.add(BugFix.new('file3.rb', '12-10-2010', nil))
    sut.add(BugFix.new('file4.rb', '13-10-2010', nil))
    assert_equal(%w(file2.rb file3.rb file4.rb).sort, sut.hot_files.sort)
  end

end