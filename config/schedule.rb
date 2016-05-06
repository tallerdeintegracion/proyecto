# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#

set :environment, "development"
set :output, {:error => "log/cron_error_log.log", :standard => "log/cron_log.log"}

every 1.minute do

 # runner "ReceiveOrdersController.run", :output => 'log/shedule_logs.log' 

end

every 1.minute do

  # runner "InventarioController.run", :output => 'log/inventario_logs.log'
   

end
# Learn more: http://github.com/javan/whenever
