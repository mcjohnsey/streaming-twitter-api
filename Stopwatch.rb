class Stopwatch
  def initialize(stopwatch_name = nil)
    @start = Time.now
    @stopwatch_name = stopwatch_name
  end

  def elapsed_time
    Time.now - @start
  end
end
