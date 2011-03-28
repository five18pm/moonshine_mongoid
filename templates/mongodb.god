God.watch do |w|
  w.name = "<%= configuration[:application] %>-mongodb"

  w.interval = 30.seconds

  w.uid = '<%= configuration[:user] || 'mongodb' %>'
  w.gid = '<%= configuration[:user] || 'mongodb' %>'

  w.env = { 'RAILS_ENV' => RAILS_ENV }

  w.start         = "service mongodb start"
  w.start_grace   = 20.seconds

  w.stop          = "service mongodb stop"
  w.stop_grace    = 20.seconds

  w.restart       = "service mongodb restart"
  w.restart_grace = 30.seconds

  w.log      = File.join(RAILS_ROOT, 'log', "#{w.name}-god.log")
  w.pid_file = File.join(RAILS_ROOT, 'log', "mongodb.#{RAILS_ENV}.pid")

  w.behavior(:clean_pid_file)

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval  = 5.seconds
      c.running   = false
    end
  end

  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state      = [:start, :restart]
      c.times         = 5
      c.within        = 5.minutes
      c.transition    = :unmonitored
      c.retry_in      = 10.minutes
      c.retry_times   = 5
      c.retry_within  = 2.hours
    end
  end
end
