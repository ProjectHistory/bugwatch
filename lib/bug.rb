require 'time'

class BugFix

  attr_reader :file, :date, :sha

  def initialize(file, date, sha)
    @file = file
    @date = Time.parse(date)
    @sha = sha
  end

end

class BugReport

  attr_reader :file, :line_number, :exception

  def initialize(file, line_number, exception)
    @file = file
  end
end