class BugCache

  attr_reader :bugs_cache
  attr_accessor :limit, :files

  def initialize(pre_cache=[], files=30)
    @pre_cache = pre_cache
    @bugs_cache = Hash.new {|h, k| h[k] = []}
    @limit = 10
    @files = files
  end

  def cache_limit
    files / limit
  end

  def sorted_cache
    bugs_cache.sort_by do |file, bugs|
      bugs.count
    end.sort_by do |file, bugs|
      -bugs_cache.values.index(bugs)
    end
  end

  def hot_files
    sorted_cache.take(cache_limit).map(&:first)
  end

  def add(*bugs)
    bugs.each do |bug|
      bugs_cache[bug.file] << bug
    end
  end

end