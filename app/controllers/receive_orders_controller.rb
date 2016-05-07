class ReceiveOrdersController < ApplicationController
  
extend  ApplicationHelper
extend ReceiveOrdersHelper
extend InventarioHelper
include ApplicationHelper
include InventarioHelper


def self.run
 	
  	require 'net/ssh'
    require 'net/sftp'
    require 'rubygems'
    require 'stringio'
    require 'tempfile'
    require 'nokogiri'	

  definirVariables

  #dejarStockEnDespacho(8)
  #despacharOC("572938439fda6e0300480f45")

 	puts "#{Time.now} - Iniciar descarga de pedidos"
	sftp =connect()
	searchOrders(sftp)

   
end

def self.definirVariables 
      
    @returnPoint = 400
    @bodegaPrincipal = "571262aaa980ba030058a1f3"                                                                           
    @bodegaRecepcion = "571262aaa980ba030058a1f1"
    @cuentaGrupo = "571262c3a980ba030058ab5d"
    @cuentaFabrica = JSON.parse(getCuentaFabrica)["cuentaId"]
    @idGrupo = "571262b8a980ba030058ab51"

  end 


def self.connect()
   	

    #cambiar a produccion
    p '--- Conectandose a Sftp'
    host = 'mare.ing.puc.cl'
    username = 'integra3'
    password = 'm3fzRPd5'
    port = 22

    sftp = Net::SFTP.start(host, username, :password => password) 
        
    return sftp
 	
	
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
  require 'json'
  #puts "Trabajando en la orden id: "+ id+ "   sku: "+sku+"   cantidad: "+cantidad+"\n"
  #puts "--- Procesando orden Id Orden: " + id + " sku: " + sku + " cantidad: " + cantidad 
  #se validará que la oc del ayudante sea correcta, o sea, que el id sea el mismo para el sku  
  oc = JSON.parse(obtenerOrdenDeCompra(id))
  if oc.nil?
      return 0
  end   

  id_prueba = oc[0]['_id'].to_s
  id_proveedor = oc[0]['proveedor'].to_s
  sku_prueba = oc[0]['sku'].to_s
  cantidad_prueba = oc[0]['cantidad'].to_s


  if(id == id_prueba && @idGrupo == id_proveedor && sku == sku_prueba && cantidad == cantidad_prueba)
    #puts "--- La oreden de compra existe en el sistema"+"\n"
  else
    rechazarOrdenDeCompra(id, "OC no existe en el sistema o tiene errores")
    Oc.find_or_create_by(oc: id , estados: "defectuosa", canal: oc[0]['canal'].to_s, factura: "", pago: "", sku: oc[0]['sku'].to_s, cantidad: oc[0]['cantidad'].to_s)#los estados son: defectuosa, aceptada, rechazada
    puts "--- ERROR la orden no existe en el sistema o tiene errores"+"\n"
    return 0        
  end  
  #vaciarStockBodegaChica() #método para resetear este dato y visualizar mejor los cambios
  #vaciarOCdb()
  ret = analizarOC(id)
 # puts "--- La oc ya ha sido procesada "

  if ret == true
<<<<<<< HEAD
    puts "A ingresado una nueva orden de compra"
=======
      puts "La factura del ftp fue generada" 
>>>>>>> 9b8d8ce3f549b8c76c3bc9c1834f2c1dee78b545
     Thread.new do
      fact = JSON.parse(emitirFactura(id))
      ocBD = Oc.find_by(oc: id)
      ocBD.update(factura: fact["_id"])
      puts "La factura del ftp fue generada" 
      verSiEnviar(fact["_id"])
      puts "La oc del ftp fue despachada" 
     end
  end

end



end