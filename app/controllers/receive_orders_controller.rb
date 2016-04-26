class ReceiveOrdersController < ApplicationController
  

def self.run
 	
  	
  	require 'nokogiri'

 	puts "#{Time.now} - iniciar descarga de pedidos"

 	serverDevCredentials()
	connect()
	

     # grab data off the remote host directly to a buffer
    #files = @sftp.download!('/pedidos')

   		
   
end


private
   def self.connect()
   		require 'net/ssh'
    	require 'net/sftp'
    	require 'rubygems'
    	require 'stringio'

        p 'ESTABLISH SFTP CONNECTION'
        host = 'mare.ing.puc.cl'
        username = 'integra3'
        password = 'm3fzRPd5'
        port = 22

        sftp = Net::SFTP.start(host, username, :password => password) 
 		 # grab data off the remote host directly to a buffer
 		
 		# create a directory
  		
  		#data = sftp.download!("/pedidos" , "/home/cristobal/Archivos" , :recursive => true)

  		sftp.dir.foreach("/pedidos") do |entry|
  		puts entry.name
  		io = StringIO.new
  		data = sftp.download!("/pedidos/"+ entry.name , io)
		end

  		# grab data off the remote host directly to a buffer
	 	 #data = sftp.download!("sftp://mare.ing.puc.cl/pedidos")


       	
        p 'CONNECTION ESTABLISHED '
end 

def self.serverDevCredentials
	@server = "mare.ing.puc.cl"
  	@user = "integra3"
	@password = "m3fzRPd5"	
end

def getOrdenDeCompra
	
end


end
