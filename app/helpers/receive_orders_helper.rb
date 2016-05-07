module ReceiveOrdersHelper


def analizarOC(id)
	require 'json'
    #puts "oc cantidad: "+ oc[0]['cantidad'].to_s+ " . oc sku: "+ oc[0]['sku'].to_s+"\n"
  oc = JSON.parse(obtenerOrdenDeCompra(id))
  if oc.nil?
      return false
  end  

  sku = oc[0]['sku'].to_s
  cantidad = oc[0]['cantidad'].to_s
  canal = oc[0]['canal'].to_s

  oc_db = Oc.find_by(oc: id)  
    #oc_db.update(estados: 'creada')
  if oc_db.nil? #si es nula se crea más abajo          
  elsif oc_db.estados == "rechazada" || oc_db.estados == "defectuosa"
  	return false #no se sigue con esta oc porque está rechazada o defectuosa
  elsif oc_db.estados == "aceptada" || oc_db.estados == "Pagada"  || oc_db.estados == "Despachada" #si es que preguntan de nuevo, ya no se procesa
  	return true
  end    
  		#SE ASUME QUE QUE SÍ SE PUEDEN TRABAJAR SKU QUE NO PRODUZCA, SIEMPRE QUE TENGA. 
	    #se validará que se tenga stock por ahora para satisfacer el pedido, sino se tiene se rechaza:
	    stock = getStockSKUDisponible(sku)#@bodegaPrincipal)
	    puts "### Stock del sku " + sku.to_s + " es de " + stock.to_s + " y piden "+cantidad.to_s+"\n"
	    if cantidad.to_i > stock.to_i
	      #se anula la oc
	      rechazarOrdenDeCompra(id, "No tenemos aún el sku requerido")
	      
          Oc.find_or_create_by(oc: id , estados: "rechazada", canal: canal, factura: "", pago: "", sku: sku, cantidad: cantidad)#los estados son: defectuosa, aceptada, rechazada
	      
	      #Oc.find_by(oc: id).update(estados: 'rechazada')
	      puts "oc " + id.to_s + " rechazada por falta de stock "+"\n"
	      return false
	    else
		      	  #se continúa con la oc, aceptando y dando la factura
			      oc_aceptada = JSON.parse(recepcionarOrdenDeCompra(id)) #este método acepta la orden de compra
			      if oc_aceptada.nil?
			          Oc.find_or_create_by(oc: id , estados: "rechazada", canal: canal, factura: "", pago: "", sku: sku, cantidad: cantidad)#los estados son: defectuosa, aceptada, rechazada
			          puts "oc " + id.to_s + " rechazada por error al recepcionarOrdenDeCompra "+"\n"	
			          return false
			      end 

			      Oc.find_or_create_by(oc: id , estados: "aceptada", canal: canal, factura: "", pago: "", sku: sku, cantidad: cantidad)#los estados son: defectuosa, aceptada, rechazada
			      #Oc.find_by(oc: id).update(estados: 'aceptada')
			      

			      #YA NO MUEVE STOCK, SINO QUE ACTUALIZA LA TABLA SKUS
			      fila_sku = Sku.find_by(sku: sku.to_s)
			      reservado = fila_sku["reservado"]
			      nuevo_reservado = reservado.to_i + cantidad.to_i
			      fila_sku.update(reservado: nuevo_reservado)
			      puts "antiguo reservado " + reservado.to_s + " nuevo reservado " + nuevo_reservado.to_s + " sku " + sku.to_s + "\n"  
			      return true
		      #end	      
	    end
	 
	#nunca debería llegar a este punto
    return true
end

def vaciarStockBodegaChica()
	require 'json'
    #puts "oc cantidad: "+ oc[0]['cantidad'].to_s+ " . oc sku: "+ oc[0]['sku'].to_s+"\n"
  arreglo = JSON.parse(getSKUWithStock("571262aaa980ba030058a23d"))#bodegaChicaQueGuardaElStockMarcadoAProducir
  if arreglo.nil?
      return false
  end  
  array = []  
#=begin
  for counter in 0..(arreglo.length-1)
    array.push(arreglo[counter]['_id'].to_s)    
  end
#=end
  #puts array[0] + "      ZZZZZZ   " + array[1] + "   " + array[2] + "\n"

  array.each do |sku| 
    productos = JSON.parse(getStock('571262aaa980ba030058a23d' , sku.to_s ) )
    if productos.nil?
    else
    	for counter in 0..(productos.length-1) 
    		#id_prod = productos[counter]['_id'].to_s
    		#puts id_prod
      		moverStock( productos[counter]['_id'].to_s, '571262aaa980ba030058a1f3' )	#la mueve a la principal
    	end
    end
  end
  return true
end

def vaciarOCdb()

	@object = Oc.all#Oc.find_by(oc: id)
	#User.where(age: 20).destroy_all

	@object.each do |o|
   	 o.delete
   	end
end

def ObtenerEspacioAlmacen(idAlmacen)
	require 'json'
	almacenes = JSON.parse(getAlmacenes())
	if almacenes.nil?
    else
    	for counter in 0..(almacenes.length-1)       		
      		if(almacenes[counter]['_id'].to_s == idAlmacen)
      			return (almacenes[counter]['totalSpace'].to_i - almacenes[counter]['usedSpace'].to_i)
      		end
    	end
    end
    return 0
end
#método sacado de inventario_controller.rb
def checkStock(sku , bodega)
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

#método sacado de inventario_controller.rb
def checkStock(sku , bodega)
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
