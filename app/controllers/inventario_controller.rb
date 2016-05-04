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
  vaciarAlmacenesRecepcion(@bodegaRecepcion, @bodegaPulmon , @bodegaPrincipal)
  checkMateriasPrimas(@bodegaPrincipal)
  checkCompraMaterial(@bodegaPrincipal)
  producirMaterialesProcesados(@bodegaPrincipal)
 

  end

	
  def self.definirVariables 
  		
  	@returnPoint = 1000
  	@returnPointProcesados = 400
  	@bodegaPrincipal = "571262aaa980ba030058a1f3"
  	@bodegaRecepcion = "571262aaa980ba030058a1f1"
  	@bodegaPulmon = "571262aaa980ba030058a23e"
  	@cuentaGrupo = "571262c3a980ba030058ab5d"
  	@GrupoProyecto="3";
  	@cuentaFabrica = JSON.parse(getCuentaFabrica)["cuentaId"]
  	@horasEntrega = 4

  end	
  

  def self.generarOrdenesDeCompra(sku , cantidad , precioUnitario, grupo )
  	require 'json'
  	require 'rubygems'
  	## get id grupo
  	canal ="b2b"
  	nota = "LoQuieroAhora" ## no deven haver espacioss
  	resp = Grupo.find_by(nGrupo: grupo.to_i) 
  	proveedor = resp.idGrupo 	
  	resp = Grupo.find_by(nGrupo: @GrupoProyecto) 
  	cliente = resp.idGrupo 	
  	puts "Generando orden canal: " + canal + " proveedor: " + proveedor + " cliente: " + cliente + " cantidad: " + cantidad.to_s
  	fechaHoy = Time.now.to_i*1000
  	fechaEntrega= fechaHoy + 4*3600*1000
  	if cliente.empty? or proveedor.empty?
  		return nil
  	end	
  	String orden = eval(crearOrdenDeCompra(canal , cantidad , sku , cliente , proveedor , precioUnitario ,   fechaEntrega , nota ))
  
  	json = orden.to_json
  	puts json  + "SDFsdfasdfasdfasdfsadf"
  	unHash = JSON.parse(json)
  	retorno = unHash["_id"]
  	return retorno
  
  end	
  
  def self.producirMaterialesProcesados(bodega)
	puts "5) #{Time.now}  Revisando si es necesario producir productos procesados"
		materias = Sku.where("grupoProyecto = ? AND tipo = ?"  , @GrupoProyecto , "Producto procesado")
  		materias.each do |row|
  		
  			revisarMaterialProcesado(row)
  		end		  	
  end	
  def self.revisarMaterialProcesado(row)

  			sku = row.sku
  			coste = row.costoUnitario
  			tamañoLote = row.loteProduccion

  			puts "### Mterial " + sku.to_s + " coste " + coste.to_s + "  "+tamañoLote.to_s

  			stock = checkStock(sku, bodega)
  			puts "### Stock del sku " + sku.to_s + " es de " + stock.to_s 
	
 			produccion = enProduccion(sku)
 			puts "### Existen en produccion " + produccion.to_s

  			lotes = calcularLotes(stock, produccion , tamañoLote, @returnPoint)
 			puts "### Lotes faltantes " + lotes.to_s

 			maxLotes =  numeroLotesPosible(sku , bodega )
 			puts "Maximo de lotes aproducir "+ maxLotes.to_s

 			produccion = 0
 			if maxLotes > lotes
 				produccion = lotes
 			else
 				produccion = maxLotes
 			end	  
 			if produccion == 0
 				return
 			end
 			producirMaterialProcesado(sku , produccion, tamañoLote)

  end	
  def self.llevarADespacho(sku , cantidad , destino)
  
  	

  end	
  def self.numeroLotesPosible(sku , bodega )
  		materias = Formula.where("sku = ?"  , sku)
 		maxLotes = 100
 		materias.each do |ing|

			skuMaterial = ing.skuIngerdiente
			nececidad = ing.requerimiento	
			stockMaterial = checkStock(skuMaterial , bodega)
			lotes = (stockMaterial/nececidad).to_i
			if maxLotes > lotes
				maxLotes=lotes
			end	

 		end	
 		return maxLotes
  end 
  def self.producirMaterialProcesado(sku , lotes , tamañoLote)
  		materias = Formula.where("sku = ?"  , sku)
 		materias.each do |ing|

 		
 		end
  end


  def self.checkCompraMaterial(bodega)

  	puts "4) #{Time.now}  Revisando si son necesarios comprar material para productos procesados "

  	prod = Sku.where("grupoProyecto = ? AND tipo = ?"  , @GrupoProyecto , "Producto procesado")
  	prod.each do |row|

  		sku = row.sku
  		puts "Revisando materias primas de "+ sku

  		materias = Formula.where("sku = ?"  , sku)
 			materias.each do |ing|
			revisarIngrediente(ing , bodega)			

 		end	
  	end
 	
  end

  def self.revisarIngrediente (ing , bodega)
  	skuMaterial = ing.skuIngerdiente
 	stock = checkStock(skuMaterial, bodega)
  	puts "######## Stock del sku " + skuMaterial + " es de " + stock.to_s 
  	resp = Sku.find_by(sku:skuMaterial)
  	grupo =  resp.grupoProyecto 
  	
  	cantidadOrden = tamañoOrden(stock , skuMaterial , grupo)
  	if cantidadOrden <= 0
  		return
  	end	

  	resp = Precio.find_by(sku:skuMaterial)
  	precioOrden = resp.precioUnitario
  	id = generarOrdenesDeCompra(skuMaterial , cantidadOrden , precioOrden , grupo)
  	puts "El id es " + id.to_s 

  	if id.nil?
  		puts "Id de la orden es nulo "
  		return
  	end	
  	
  	aceptado = sendOc(grupo , id)				
  	puts "##### Aceptada : " + aceptado.to_s
  	if aceptado == false
  		data = anularOrdenDeCompra(id , "Fue rechazada")
  		puts "orden anulada " + data 
  		return
  	end 
  	
  	put "Oc fue aceptada"
  	
  			
  end	

 

  def self.tamañoOrden(stock , skuMaterial , grupo)
	faltante = @returnPoint -(stock + pedidas(skuMaterial))
  	puts "######## faltan " + faltante.to_s + " pidiendo al grupo " + grupo.to_s 
  	stock = getStockOfGroup(skuMaterial , grupo)
  	puts "######## El grupo tiene stock de  " + stock.to_s  
  	if faltante <= 0
  		puts "######## No es necesario comprar stock" 
  		return 0  
  	else
  	orden = 0
  		if stock < 0 
  			puts "######## No existe inventario "
  			return 0
  		elsif faltante > stock			
	  		puts "######## Genereando la oc"
  			return stock

  		else
  			puts "######## Genereando la oc"
  			return faltante
  		end	
  	end	

  end 	

  def self.getStockOfGroup(sku , group)
  	url = "http://integra"+group+".ing.puc.cl/api/consultar/" +sku
  	resp = httpGetRequest( url, nil)
  	
  	if valid_json?(resp) ==false
  		return -1
  	end

  	json =JSON.parse(resp)
  	stock = json["stock"]
  	return  stock

  end

  def self.sendOc(group , oc)
  	url = "http://integra"+ group.to_s + ".ing.puc.cl/api/oc/recibir/" +oc
  	puts "sending " + url  
  	resp = httpGetRequest( url, nil)
  
  	if valid_json?(resp) ==false
  		return false
  	end
  	json =JSON.parse(resp)
  	puts  "El grupo respondio " + json.to_s
  	aceptado = json["aceptado"]
  	
  	return  aceptado
  end

  def self.pedidas(sku)
  		sent = SentOrder.where(sku: sku)
  		if sent.nil?
	  		return 0
  		else
  			return sent.sum("cantidad")
  		end
  end	


  def self.checkMateriasPrimas(bodega)

  ##TODO sacar info de bases de datos y replicas 
  puts "3) #{Time.now}  Revisando si son necesarias materias primas "  
  materias = Sku.where("grupoProyecto = ? AND tipo = ?"  , @GrupoProyecto , "Materia Prima")

  materias.each do |row|
  	
  		sku = row.sku
  		coste = row.costoUnitario
  		tamañoLote = row.loteProduccion

  		puts "### Mterial " + sku.to_s + " coste " + coste.to_s + "  "+tamañoLote.to_s

  		stock = checkStock(sku, bodega)
  		puts "### Stock del sku " + sku.to_s + " es de " + stock.to_s 
	
 		produccion = enProduccion(sku)
 		puts "### Existen en produccion " + produccion.to_s

  		lotes = calcularLotes(stock, produccion , tamañoLote, @returnPoint)
 		puts "### Lotes a producir " + lotes.to_s
  
  		monto = lotes*coste*tamañoLote	
 		if lotes <= 0
 			puts "### No es necesario producir"	
 		else

  		trx =pagar(monto , @cuentaGrupo , @cuentaFabrica  );
  		puts "### Transferencia exitosa " + trx

  		cantidad= lotes*tamañoLote
  		detallesProd = producir(sku, trx, cantidad)
  		puts detallesProd
  		p "### se enviaro a producir " + cantidad.to_s + " de la transaccion " +trx 
  		actualizarRegistoProduccion(detallesProd , sku , cantidad)
  		end
 	end	 

  end	


  def self.actualizarRegistoProduccion(detallesProd , sku , cantidad)

  jsonDetalles = JSON.parse(detallesProd)
  disponible= jsonDetalles["disponible"]
  puts "Producioendo , disponible en " + disponible.to_s  
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

  def self.vaciarAlmacenesRecepcion(bodegaRecepcion , bodegaPulmon, bodegaPrincipal)
	
	puts "2) #{Time.now} Reciviendo materias primas "

  	materias = Sku.where("grupoProyecto = ? AND tipo = ?"  , @GrupoProyecto , "Materia Prima")
  		materias.each do |row|
  		sku = row.sku	
  		recibirMaterial(sku, bodegaRecepcion, bodegaPrincipal)
  		recibirMaterial(sku, bodegaPulmon, bodegaPrincipal)
  	end

  	materias = Sku.where("grupoProyecto = ? AND tipo = ?"  , @GrupoProyecto , "Producto procesado")
  		materias.each do |row|
  		sku = row.sku	
  		recibirMaterial(sku, bodegaRecepcion, bodegaPrincipal)
  		recibirMaterial(sku, bodegaPulmon, bodegaPrincipal)

  		ingrediente = Formula.where("sku = ?"  , sku)
 			ingrediente.each do |ing|
			skuMaterial = ing.skuIngerdiente	
			recibirMaterial(skuMaterial, bodegaRecepcion, bodegaPrincipal)
  			recibirMaterial(skuMaterial, bodegaPulmon, bodegaPrincipal)
		

 		end	

  	end

  end	


  def self.recibirMaterial( sku , almacenRecepcion , bodegaMateriasPrimas)
  		  		
  		stock = checkStock(sku ,almacenRecepcion) 
		stockInicial = stock	

  		puts "### Stock de "+ sku +" cantiad: " +  stock.to_s + " disponibles en almacen de recepcion "	+ almacenRecepcion

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
		return stockInicial
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

  

end
