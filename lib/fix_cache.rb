class BugSort

  attr_reader :bug_fixes

  def initialize(bug_fixes)
    @bug_fixes = bug_fixes
  end

  def <=>(other_bug_sort)
    if bug_fixes.count < other_bug_sort.bug_fixes.count
      1
    elsif bug_fixes.count == other_bug_sort.bug_fixes.count
      other_bug_sort.bug_fixes.last.date <=> bug_fixes.last.date
    else
      -1
    end
  end

end

class FixCache

  attr_reader :cache
  attr_accessor :limit

  def initialize(file_count, limit=10)
    @cache = Hash.new {|h, k| h[k] = []}
    @file_count = file_count
    @limit = limit
  end

  def add(*fixes)
    fixes.each do |fix|
      cache[fix.file] << fix
    end
  end

  def hot_files
    cache.sort_by do |_, fixes|
      BugSort.new(fixes)
    end.take(cache_limit).map(&:first)
  end

  def cache_limit
    @file_count / limit
  end

end