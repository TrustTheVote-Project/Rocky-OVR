class PassengerMonitor
  
  # How much memory (MB) single Passenger instance can use
  DEFAULT_MEMORY_LIMIT = 250
  # How long should we wait after graceful kill attempt, before force kill
  WAIT_TIME = 10

  def self.cleanup(params = {})
    new(params).check
  end

  # Set up memory limit, log file and logger
  def initialize(params = {})
    @memory_limit = params[:memory_limit] || DEFAULT_MEMORY_LIMIT
  end

  # Check all the Passenger processes
  def check
    puts 'Checking for bloated Passenger workers' 

    `passenger-memory-stats`.each_line do |line|
next unless (line =~ /Passenger AppPreloader: /)

      pid, memory_usage =  extract_stats(line)
      puts "Pid #{pid} using mem #{memory_usage}"
      # If a given passenger process is bloated try to
      # kill it gracefully and if it fails, force killing it
      if bloated?(pid, memory_usage)
        kill(pid)
        wait
        if process_running?(pid)
          kill(pid)
          wait
        end
        if process_running?(pid)
          kill(pid)
          wait
        end
        kill!(pid) if process_running?(pid)
      end
    end

    puts 'Finished checking for bloated Passenger workers'
  end

  private

  # Check if a given process is still running
  def process_running?(pid)
    Process.getpgid(pid) != -1
  rescue Errno::ESRCH
    false
  end

  # Wait for process to be killed
  def wait
    puts "Waiting for worker to shutdown..."
    sleep(WAIT_TIME)
  end

  # Kill it gracefully
  def kill(pid)
    puts "Trying to kill #{pid} gracefully..."
    Process.kill("SIGUSR1", pid)
  end

  # Kill it with fire
  def kill!(pid)
    puts "Force kill: #{pid}"
    Process.kill("TERM", pid)
  end

  # Extract pid and memory usage of a single Passenger
  def extract_stats(line)
    stats = line.split
    return stats[0].to_i, stats[3].to_f
  end

  # Check if a given process is exceeding memory limit
  def bloated?(pid, size)
    bloated = size > @memory_limit
    puts "Found bloated worker: #{pid} - #{size}MB" if bloated
    bloated
  end

end


