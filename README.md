What is Bugwatch?
----
Bugwatch provides a strategy for importing rich SCM data, and performs code analysis through a series of custom analyzers.

What can I use Bugwatch for?
----
- pluggable static analysis (complexity, churn)
- realtime metrics and developer feedback

How do I use Bugwatch?
----

1. Discover your repo
```
bugwatch_repo = Bugwatch::Repo.discover(repo_name, path_or_url_to_repo)
```
(This will clone your repo to the relative path "repos/repo_name")

2. Set up caching strategy (see [Caching Strategy](#caching-strategy))
```
cache_strategy = ActiveRecordCache.new(bugwatch_repo)
```

2. Import and Analyze
```
analyzer = -> bugwatch_commit { puts "Analyzing #{bugwatch_commit.sha}!" }
bugwatch_repo.analyze!(cache_strategy, [analyzer], 'sha') # imports and analyzes. begins at sha and walks SCM history
```

Import only
----
Sometimes you don't need to run analyzers
```
bugwatch_repo.import(cache_strategy, 'sha') # imports all commits if sha is nil
```

Analyze only
----
Run analyzers without importing new commits
```
bugwatch_repo.analyze(cache_strategy, [analyzer], 'sha') # analyzes all commits if sha is nil
```

Caching Strategy
----
A caching strategy is required for gradual import and analysis of SCM commits. 
The caching strategy is also responsible for storing commits and analysis metadata.

Example:
```
class ActiveRecordCache
  def initialize(actice_record_repo) 
    @repo = active_record_repo
  end
  
  def imported
    # return collection of commit shas that have already been imported
    @repo.commits.pluck(:sha)
  end
  
  def analyzed(key)
    # return collection of commit shas that have been analyzed by key
    @repo.commits.joins(:analysis_histories).where('analysis_histories.key = ?', key).pluck(:sha)
  end
  
  def store(bugwatch_commit)
    # store commit data
    @repo.commits.create!(sha: bugwatch_commit.sha)
  end
  
  def store_analysis(bugwatch_commit, key)
    # store commit analysis metadata
    commit = @repo.commits.find_by_sha(bugwatch_commit.sha)
    commit.analysis_histories << AnalysisHistory.new(key: key)
  end
end
```

Custom Analyzers
----
Bugwatch analyzers are objects that:
  1. respond to `call` and take one argument of type `Bugwatch::Commit`
  2. respond to `key` for storing/versioning

Example:
```
class ComplexityAnalyzer
  def self.call(bugwatch_commit)
    complexity_score = bugwatch_commit.flog.total_score
    Commit.create sha: bugwatch_commit.sha, complexity: complexity_score
  end
  
  def self.key
    'ComplexityAnalyzer-1'
  end
end
```
