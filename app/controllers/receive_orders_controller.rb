class ReceiveOrdersController < ApplicationController
  
extend  ApplicationHelper

def self.run
 	
  	require 'net/ssh'
    require 'net/sftp'
    require 'rubygems'
    require 'stringio'
    require 'tempfile'
    require 'nokogiri'	

  definirVariables

 	puts "#{Time.now} - iniciar descarga de pedidos"
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
    p 'ESTABLISH SFTP CONNECTION'
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
  puts "Trabajando en la orden id: "+ id+ "   sku: "+sku+"   cantidad: "+cantidad+"\n"

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
    puts "oc existente en el sistema"+"\n"
  else
    rechazarOrdenDeCompra(id, "OC no existe en el sistema o tiene errores")
    puts "oc NO EXISTE en el sistema o tiene errores"+"\n"
    return 0
  end
  #puts "oc cantidad: "+ oc[0]['cantidad'].to_s+ " . oc sku: "+ oc[0]['sku'].to_s+"\n"

  
  if sku != "6" && sku != "55" && sku != "49" && sku != "8" && sku != "14" && sku != "31" #&& sku != "52" && sku != "20" && sku != "2" && sku != "7"
    #si no son los sku que producimos (son 6). Los 4 faltantes los requerimos pero no producimos 
    rechazarOrdenDeCompra(id, "No producimos algunos de los requerimientos")
    puts "oc " + id.to_s + " rechazada por no producir sku "+sku.to_s+"\n"
  else 
    #se validará que se tenga stock por ahora para satisfacer el pedido, sino se tiene se rechaza:
    stock = checkStock(sku, @bodegaPrincipal)
    puts "### Stock del sku " + sku.to_s + " es de " + stock.to_s + " y piden "+cantidad.to_s+"\n"
    if cantidad.to_i > stock.to_i
      #se anula la oc
      rechazarOrdenDeCompra(id, "No tenemos aún los requerimientos en bodega")
      puts "oc " + id.to_s + " rechazada por falta de stock "+"\n"
    else
       #se continúa con la oc, aceptando y dando la factura
      oc_aceptada = JSON.parse(recepcionarOrdenDeCompra(id)) #este método acepta la orden de compra
      if oc_aceptada.nil?
          return 0
      end   
      #no se valida que devuelva error porque no debería, si la oc ya se comprobó que existe
      factura = JSON.parse(emitirFactura(id))
      #comprobar que el monto sea el correcto, por siaca:
      
    end
  end

end

#método sacado de inventario_controller.rb
def self.checkStock(sku , bodega)
    require 'json'
    result = JSON.parse(getSKUWithStock(bodega))
  
    if result.nil?
      return 0
    end 

    stock =0
    #productos = result.length.to_s
    #puts "###   " + productos +"\n"
    #result.each do |player| 
    #  current_position = player.to_s#['_id'].to_s
    #  puts "     " + current_position +"\n"
    #end
  for counter in 0..(result.length-1)
    actualSku =result[counter]['_id'].to_s
    if(sku == actualSku)
      actualTotal =result[counter]['total'].to_i
      stock = actualTotal
      return stock 
    end
  end

  if stock.nil?
    # Error 
    return 9000000 
  end
  return stock
      
end

end