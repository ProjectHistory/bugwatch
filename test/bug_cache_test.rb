require_relative 'test_helper'
require 'bug_cache'
require 'bug'

class BugCacheTests < Test::Unit::TestCase

  def sut(pre_cache=[])
    @sut ||= BugCache.new(pre_cache)
  end

  def test_hot_files_returns_files_in_cache
    sut.add(Bug.new('file1.rb', 2, ''), Bug.new('file2.rb', 1, ''))
    assert_equal(['file2.rb', 'file1.rb'], sut.hot_files)
  end

  def test_hot_files_are_unique
    sut.add(Bug.new('file1.rb', 2, ''), Bug.new('file1.rb', 1, ''))
    assert_equal(['file1.rb'], sut.hot_files)
  end

  def test_add_adds_bug_to_cache
    sut.add(Bug.new('file1.rb', 2, ''))
    assert_equal(['file1.rb'], sut.hot_files)
  end

  def test_add_replaces_oldest_bug_if_over_threshold
    sut.limit = 10
    sut.files = 20
    sut.add(Bug.new('file1.rb', 2, ''), Bug.new('file2.rb', 1, ''), Bug.new('file2.rb', 2, ''))
    sut.add(Bug.new('file3.rb', 1, ''))
    assert_equal(['file3.rb', 'file2.rb'], sut.hot_files)
  end

end