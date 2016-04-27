class ReceiveOrdersController < ApplicationController
  

def self.run
 	
  	require 'net/ssh'
    require 'net/sftp'
    require 'rubygems'
    require 'stringio'
    require 'tempfile'
    require 'nokogiri'	


 	puts "#{Time.now} - iniciar descarga de pedidos"
	sftp =connect()
	searchOrders(sftp)

   
end


def self.connect()
   	

    #cambiar a produccion
    p 'ESTABLISH SFTP CONNECTION'
    host = 'mare.ing.puc.cl'
    username = 'integra3'
    password = 'm3fzRPd5'
    port = 22

    sftp = Net::SFTP.start(host, username, :password => password) 
 	
	
end 



def self.searchOrders (sftp)
	
		# create a temporary directory 
  		Dir.mktmpdir do |dir|
  		data = sftp.download!("/pedidos" , dir , :recursive => true)

  			Dir.glob(dir+"/*.xml") do |fname|
  			# do work on files ending in .xml in the desired directory
  			#puts fname

  			doc = Nokogiri::XML(File.open(fname))
  			sku=doc.css("order sku").first.text
  			id=doc.css("order id").first.text
  			qty=doc.css("order qty").first.text
  			processOrder(id , sku , qty)
			end
  			
  		end

	puts "#{Time.now} - Pedidos procesados \n"

end

def self.processOrder(id , sku , cantidad)

puts "Trabajando en la orden id: "+ id+ "   sku: "+sku+"   cantidad: "+cantidad+"\n"

end

end