# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#

##Cambiar el enviroment production

set :environment, "production"
set :output, {:error => "log/cron_error_log.log", :standard => "log/cron_log.log"}

every '0,30 * * * *' do

 runner "ReceiveOrdersController.run", :output => 'log/shedule_logs.log' 

end

every 1.minute do

 runner "InventarioController.recibir", :output => 'log/vaciar_inventario_logs.log'
 
end

every '15,45 * * * *' do

 runner "InventarioController.run", :output => 'log/inventario_logs.log'

end

every 1.hour do

 runner "SocialMediaController.search", :output => 'log/promotion_logs.log'
 
end
# Learn more: http://github.com/javan/whenever
every 1.day, :at => '11:59 pm' do
	runner "HomeController.guardaSaldoDiarioYStock"#, :output => 'log/inventario_logs.log'

end
