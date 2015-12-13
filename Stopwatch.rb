class Stopwatch
  def initialize(stopwatch_name = nil)
    @start = Time.now
    @stopwatch_name = stopwatch_name
  end

  def elapsed_time
    Time.now - @start
  end

  def elapsed_seconds
    elapsed_time.to_i
  end

  def to_s
    stopwatch_name = @stopwatch_name.nil? ? 'Stopwatch' : @stopwatch_name
    "#{stopwatch_name} (s): #{elapsed_time.to_i}"
  end
end
