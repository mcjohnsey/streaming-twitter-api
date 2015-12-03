class Stopwatch

  def initialize(stopwatch_name = nil)
    @start = Time.now
    @stopwatch_name = stopwatch_name
  end

  def elapsed_time
    # puts @stopwatch_name if !@stopwatch_name.nil?
    now = Time.now
    elapsed = now - @start
    # puts 'Started: ' + @start.to_s
    # puts 'Now: ' + now.to_s
    # puts 'Elapsed time: ' +  elapsed.to_s + ' seconds'
    elapsed
  end

end
