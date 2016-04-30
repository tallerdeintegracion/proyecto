class InventarioController < ApplicationController
 	
 	
 	extend	ApplicationHelper
 	#include	ProductOrdersController
 	

#6	Crema	Producto procesado	3	Lts	  2,402 	  30 	0.979
#8	Trigo	Materia prima	3	Kg	  1,313 	  100 	0.784
#14	Cebada	Materia prima	3	Kg	  696 	  1,750 	1.355
#31	Lana	Materia prima	3	Mts	  1,434 	  960 	3.449
#49	Leche Descremada	Producto procesado	3	Lts	  1,459 	  200 	4.281
#55	Galletas Integrales	Producto procesado	3	Kg	  2,284 	  950 	3.955

  
  def self.run
  
  definirVariables 
  puts "\n \n #{Time.now}  Inicia revicion de inventario "
  
  cleanProduccionesDespachadas()
  recibirMateriasPrimas(@bodegaRecepcion , @bodegaPrincipal)
  checkMateriasPrimas(@bodegaPrincipal)
  end
	
  def self.definirVariables 
  		
  	@returnPoint = 400
  	@bodegaPrincipal = "571262aaa980ba030058a1f3"
  	@bodegaRecepcion = "571262aaa980ba030058a1f1"
  	@cuentaGrupo = "571262c3a980ba030058ab5d"
  	@cuentaFabrica = JSON.parse(getCuentaFabrica)["cuentaId"]

  end	
  def self.checkMateriasPrimas(bodega)

  ##TODO sacar info de bases de datos y replicas 
  puts "3) #{Time.now}  Revisando si son necesarias materias primas "
  sku = "8"	
  coste =1313
  tamañoLote = 100


  stock = checkStock(sku, bodega)
  puts "### Stock del sku " + sku.to_s + " es de " + stock.to_s 
	
  produccion = enProduccion(sku)
  puts "### Existen en produccion " + produccion.to_s

  lotes = calcularLotes(stock, produccion , tamañoLote, @returnPoint)
  puts "### Lotes a producir " + lotes.to_s
  
  monto = lotes*coste*tamañoLote	
 	if lotes <= 0
 		puts "### No es necesario producir"
 		return	
 	end
  trx =pagar(monto , @cuentaGrupo , @cuentaFabrica  );
  puts "### Transferencia exitosa " + trx
  cantidad= lotes*tamañoLote
  detallesProd = producir(sku, trx, cantidad)
  p detallesProd

 actualizarRegistoProduccion(detallesProd , sku , cantidad)
 	 

  end	

  def self.actualizarRegistoProduccion(detallesProd , sku , cantidad)

  jsonDetalles = JSON.parse(detallesProd)
  disponible= jsonDetalles["disponible"]
  Production.find_or_create_by(sku: sku , cantidad: cantidad , disponible: disponible)

  end	
  def self.pagar(monto , origen , destino)


  	trx = JSON.parse(transferir(monto , origen, destino))['_id']
  	if trx.nil?
  		p "#### Hubo un error en la transferencia !!" 
  		return	
  	end
  	return trx

  end	

  def self.producir(sku , trx , cantidad )

	prod =producirStock(sku , trx , cantidad)
	return prod


  end	

  def self.checkStock(sku , bodega)
  	require 'json'
  	result = JSON.parse(getSKUWithStock(bodega))
  
  	if result.nil?
  		return 0
  	end	

  	stock =0
	for counter in 0..(result.length-1)

		actualSku =result[counter]['_id'].to_s

		if(sku == actualSku)
			actualTotal =result[counter]['total'].to_i
			stock = actualTotal 
		end
	end

	if stock.nil?
		# Error 
		return 9000000 
	end

	return stock
  		
  end


  def self.enProduccion(sku)
  		
  	produccion = Production.where(sku: sku)
  	if produccion.nil?
  	return 0
  	else
  	return produccion.sum("cantidad")
  	end

  end


  def self.calcularLotes(stock , enproduccion , tamañoLote ,returnPoint )

  	total= stock + enproduccion
  	faltante = returnPoint - total
  	lotes = (faltante/tamañoLote).to_i
  	if lotes < 0
  		return 0
  	end	
  	return lotes

  end


  def self.cleanProduccionesDespachadas()
  	puts "1) #{Time.now}  Limpiando producciones despachadas del registro "
  	time = Time.now
  	produccion = Production.where( 'disponible <= ?', time )
	puts "### Fueron despachadas " + produccion.count.to_s
	produccion.destroy_all
  end	



  def self.recibirMateriasPrimas( almacenRecepcion , bodegaMateriasPrimas)
  		puts "2) #{Time.now} Reciviendo materias primas "
  		sku= 8 
  		stock = checkStock(sku ,almacenRecepcion) 
  		
  		puts "### Stock de " + stock.to_s + " disponibles en almacen de recepcion"	

  		if stock == 0
  			return
  		end



  		while stock > 0
  			stock = checkStock(sku ,almacenRecepcion)
			resp = JSON.parse(getStock(almacenRecepcion , sku , 200 ))
			cantidadMover = resp.length
			
			if resp.nil? | cantidadMover.nil? 
  			return
  			end
			moveProducts(resp ,cantidadMover,  bodegaMateriasPrimas )
			
  		end	
  

  end 	

  def self.moveProducts(products , cantidad , destino)
  	puts "### Moviendo  " + cantidad.to_s + " a bodega principal"
  	
  	if cantidad.nil? | products.nil? | cantidad==0
  		return
  	end	

  	for counter in 0..cantidad-1
  		id = products[counter]["_id"]
  		moverStock(id , destino)
  	end

  end	

 

  
#572283e304c78e0300ce3ee2"
#Ejemplo respuesta prod
#"{\"__v\":0,\"created_at\":\"2016-04-29T19:03:07.371Z\",\"updated_at\":\"2016-04-29T19:03:07.371Z\",\"sku\":\"8\",\"grupo\":3,\"cantidad\":200,\"_id\":\"5723afeb5f9931030058a3f0\",\"disponible\":\"2016-04-29T20:15:19.611Z\",\"despachado\":false}"
end
