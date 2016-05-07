class InventarioController < ApplicationController
 	
 	
 	extend	ApplicationHelper
 	extend  InventarioHelper
 	include ApplicationHelper
 	include InventarioHelper
 	#include	ProductOrdersController
 	

#6	Crema	Producto procesado	3	Lts	  2,402 	  30 	0.979
#8	Trigo	Materia prima	3	Kg	  1,313 	  100 	0.784
#14	Cebada	Materia prima	3	Kg	  696 	  1,750 	1.355
#31	Lana	Materia prima	3	Mts	  1,434 	  960 	3.449
#49	Leche Descremada	Producto procesado	3	Lts	  1,459 	  200 	4.281
#55	Galletas Integrales	Producto procesado	3	Kg	  2,284 	  950 	3.955

  
  def self.run
  
  definirVariables 
  puts "\n \n \n \n "
  puts "#{Time.now}  Inicia revicion de inventario "

  cleanProduccionesDespachadas()
  vaciarAlmacenesRecepcion(@bodegaRecepcion, @bodegaPulmon , @bodegaPrincipal)
  checkMateriasPrimas(@bodegaPrincipal)
  checkCompraMaterial(@bodegaPrincipal)
  producirMaterialesProcesados(@bodegaPrincipal)
 

  end

	
  def self.definirVariables 
  		
  	@returnPoint = 2000
  	@returnPointProcesados = 400
  	@bodegaPrincipal = "571262aaa980ba030058a1f3"
  	@bodegaRecepcion = "571262aaa980ba030058a1f1"
  	@bodegaPulmon = "571262aaa980ba030058a23e"
  	@bodegaDespacho = "571262aaa980ba030058a1f2"

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
  	puts "--- Generando  proveedor: " + proveedor + " cliente: " + cliente + " cantidad: " + cantidad.to_s
  	fechaHoy = Time.now.to_i*1000
  	fechaEntrega= fechaHoy + 4*3600*1000
  	if cliente.empty? or proveedor.empty?
  		return nil
  	end	
  	String orden = eval(crearOrdenDeCompra(canal , cantidad , sku , cliente , proveedor , precioUnitario ,   fechaEntrega , nota ))
  
  	json = orden.to_json
  	unHash = JSON.parse(json)
  	retorno = unHash["_id"]
  	return retorno
  
  end	
  
  
  def self.producirMaterialesProcesados(bodega)
  	puts "\n"
	puts "5) #{Time.now}  Revisando si es necesario producir productos procesados "
	puts "\n"	
		materias = Sku.where("grupoProyecto = ? AND tipo = ?"  , @GrupoProyecto , "Producto procesado")
  		materias.each do |row|
  		
  			revisarMaterialProcesado(row , bodega)
  		end		  	
  end	

  def self.revisarMaterialProcesado(row , bodega)

  			sku = row.sku
  			coste = row.costoUnitario
  			tamañoLote = row.loteProduccion

  			puts "--- Revisando material " + sku.to_s + " coste " + coste.to_s + " tamaño lote "+tamañoLote.to_s

  			stock = checkStock(sku, bodega)
  			puts "--- Stock del sku " + sku.to_s + " es de " + stock.to_s 
	
 			produccion = enProduccion(sku)
 			puts "--- Existen en produccion " + produccion.to_s

  			lotes = calcularLotes(stock, produccion , tamañoLote, @returnPoint)
 			puts "--- Lotes faltantes " + lotes.to_s

 			maxLotes =  numeroLotesPosible(sku , bodega )
 			puts "--- Maximo de lotes a producir con materias disponibles: "+ maxLotes.to_s

 			produccion = 0
 			if maxLotes > lotes
 				produccion = lotes
 			else
 				produccion = maxLotes
 			end	  
 			if produccion == 0
 				return 
 			end
 			
 			cantidad = produccion *tamañoLote
 			puts "--- Se mandaran a producir " + cantidad.to_s  + " lotes"
 			
 			exito =  llevarMateriaPrimasADespacho(sku , produccion)
 			
 			if exito == false
 				puts "--- Hubo un fallo en el movimiento de materias primas a despacho "
 				return 
 			end 
 				
 			monto = produccion * tamañoLote * coste

 			trx = pagar(monto , @cuentaGrupo , @cuentaFabrica  );
	  		puts "--- Transferencia exitosa " + trx

	  		detallesProd = producir(sku, trx, cantidad)
  			puts "--- Se enviaro a producir " + cantidad.to_s + " de la transaccion " +trx 
  			
  			actualizarRegistoProduccion(detallesProd , sku , cantidad)
  			puts "--- Registro produccion actualizado "  
 			

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

  def self.llevarMateriaPrimasADespacho(sku , lotes )
  		
  		materias = Formula.where("sku = ?"  , sku)
  		correcto ==true
 		materias.each do |ing|
 			
 			skuIngrediente = ing.skuIngerdiente
 			cantidadPorLote = ing.requerimiento
 			cantidadTotal = cantidadPorLote*lotes
 			origen = @bodegaPrincipal
 			destino = @bodegaDespacho

 			movidos = moverInventario(skuIngerdiente , cantidadTotal , @bodegaPrincipal , @bodegaDespacho)
 			if movidos != cantidadTotal
 				correcto =false
 			end	
 	
 		end
 		return correcto

  end


  def self.checkCompraMaterial(bodega)
	puts "\n"
  	puts "4) #{Time.now}  Revisando si son necesarios comprar material para productos procesados  "
  	puts "\n"

  	prod = Sku.where("grupoProyecto = ? AND tipo = ?"  , @GrupoProyecto , "Producto procesado")
  	prod.each do |row|

  		sku = row.sku
  		puts "--- Revisando materiales para producir  "+ sku

  		materias = Formula.where("sku = ?"  , sku)
 			materias.each do |ing|
			revisarIngrediente(ing , bodega)			

 		end	
  	end
 	
  end

  def self.revisarIngrediente (ing , bodega)
  	skuMaterial = ing.skuIngerdiente
  	puts "--- Revisando ingrediente   " + skuMaterial
 	stock = checkStock(skuMaterial, bodega)
  	puts "--- Stock del sku " + skuMaterial + " es de " + stock.to_s 
  	resp = Sku.find_by(sku:skuMaterial)
  	grupo =  resp.grupoProyecto 
  	cantidadOrden = tamañoOrden(stock , skuMaterial , grupo)
  	
  	if cantidadOrden <= 0
  		return
  	end	

  	resp = Precio.find_by(sku:skuMaterial)
  	precioOrden = resp.precioUnitario
  	id = generarOrdenesDeCompra(skuMaterial , cantidadOrden , precioOrden , grupo)
  	
  	if id.nil?
  		puts "--- No fue posible  ingresar orden de compra "
  		return
  	end	
  	
  	aceptado = sendOc(grupo , id)

 
  	if aceptado == false
  		data = anularOrdenDeCompra(id , "Fue rechazada")
  		puts "--- La orden fue rechazada y anulada del sistema " 
  		return
  	end 
  	
  	puts "--- La orden de compra fue aceptada "
  	actualizarRegistoOc(id )
  	
  	
  			
  end	
  def self.actualizarRegistoOc(id )

  	resp = JSON.parse(obtenerOrdenDeCompra(id)).first
  	#puts resp
  	sku = resp['sku']
  	estado = resp["estado"]
  	cantidad= resp["cantidad"]
  	fechaEntrega = resp["fechaEntrega"]
	puts fechaEntrega.to_s
  	variable = SentOrder.find_or_create_by(oc:id , sku: sku , estado: estado, cantidad: cantidad , fechaEntrega: fechaEntrega)
 	puts "--- Se registro el envio de la oc " + id+ variable.to_s
  end	
 

  def self.tamañoOrden(stock , skuMaterial , grupo)
  	pedidas = pedidas(skuMaterial)
	faltante = @returnPoint -(stock + pedidas)
  	
  	puts "--- Ya se han pedido " + pedidas.to_s

  	if faltante <= 0
  		puts "--- No es necesario comprar stock" 
  		return 0  
  	else

  	stockGrupo = getStockOfGroup(skuMaterial , grupo)
  	puts  "--- El stock reportado por el grupo es de " + stockGrupo.to_s
  	
  
  	#getStockSKUDisponible()

  	
  	orden = 0

  		if stockGrupo <= 0 
  			puts "--- El grupo no tiene stock  "
  			return 0
  		elsif faltante > stockGrupo			
	  		puts "--- Generando orden de compra por la totalidad del stock " +  stockGrupo.to_s	
  			return stockGrupo

  		else
  			puts "--- Generando orden de compra por el faltante " + faltante.to_s
  			return faltante
  		end	
  		#puts "--- pidiendo al grupo " + grupo.to_s + "  " + faltante.to_s + " unidades"
  	end	

  end 	

  def self.getStockOfGroup(sku , group)
  	url = "http://integra"+group+".ing.puc.cl/api/consultar/" +sku
  	puts "--- Consultando el stock de " + url

  	resp = httpGetRequest( url, nil)

  	if resp.nil?
  		return -1
  	end	
  	if valid_json?(resp) ==false
  		return -1
  	end

  	json =JSON.parse(resp)
  	stock = json["stock"]
  	return  stock

  end

  def self.sendOc(group , oc)
  	url = "http://integra"+ group.to_s + ".ing.puc.cl/api/oc/recibir/" +oc
  	puts "--- Enviando orden de compra a: " + url  
  	resp = httpGetRequest( url, nil)
  
  	if valid_json?(resp) ==false
  		return false
  	end

  	json =JSON.parse(resp)
  	puts "--- Respuesta " + resp
  	aceptado = json["aceptado"]
  	
  	if aceptado.nil?
  		return false
  	end	
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
  puts "\n"
  puts " 3) #{Time.now}  Revisando si es necesario producir materias primas"  
  puts "\n"
  materias = Sku.where("grupoProyecto = ? AND tipo = ?"  , @GrupoProyecto , "Materia Prima")

  materias.each do |row|
  	
  		sku = row.sku
  		coste = row.costoUnitario
  		tamañoLote = row.loteProduccion

  		puts "--- Material " + sku.to_s + " coste: " + coste.to_s + " tamaño lote: "+tamañoLote.to_s

  		stock = checkStock(sku, bodega)
  		puts "--- Stock del sku es de: " + stock.to_s 
	
 		produccion = enProduccion(sku)
 		puts "--- Existen en produccion: " + produccion.to_s

  		lotes = calcularLotes(stock, produccion , tamañoLote, @returnPoint)
 		puts "--- Lotes a producir: " + lotes.to_s
  
  		monto = lotes*coste*tamañoLote	
 		
 		if lotes <= 0
 			puts "--- No es necesario producir"	
 		else

  			trx =pagar(monto , @cuentaGrupo , @cuentaFabrica  );
	  		
	  		puts "--- Transferencia exitosa " + trx
  			cantidad= lotes*tamañoLote
  			
  			detallesProd = producir(sku, trx, cantidad)
  			puts "--- Se enviaro a producir " + cantidad.to_s + " de la transaccion " +trx 
  			
  			actualizarRegistoProduccion(detallesProd , sku , cantidad)
  			puts "--- Registro produccion actualizado "  
  		end
 	end	 

  end	


  def self.actualizarRegistoProduccion(detallesProd , sku , cantidad)

  jsonDetalles = JSON.parse(detallesProd)
  disponible= jsonDetalles["disponible"]
  puts "--- Produciendo material , disponible en " + disponible.to_s  
  Production.find_or_create_by(sku: sku , cantidad: cantidad , disponible: disponible)

  end


  def self.pagar(monto , origen , destino)

  	trx = JSON.parse(transferir(monto , origen, destino))['_id']
  	if trx.nil?
  		p "--- Hubo un error en la transferencia" 
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
  	puts "\n"
  	puts "1) #{Time.now}  Limpiando producciones despachadas del registro"
  	puts "\n"
  	time = Time.now
  	produccion = Production.where( 'disponible <= ?', time )
	puts "--- Fueron removidas  " + produccion.count.to_s + " entregas de la tabla de produccion "
	produccion.destroy_all	
	ocs = SentOrder.where( 'fechaEntrega <= NOW()')
	puts "--- Fueron removidas  " + ocs.count.to_s + " entregas de la tabla de ocs enviadas "
	ocs.destroy_all
  end	


  def self.vaciarAlmacenesRecepcion(bodegaRecepcion , bodegaPulmon, bodegaPrincipal)
	puts "\n"
	puts "2) #{Time.now} Recibiendo material de almacen de recepcion "
	puts "\n"

  	materias = Sku.where("grupoProyecto = ? AND tipo = ?"  , @GrupoProyecto , "Materia Prima")
  		materias.each do |row|
  		sku = row.sku	
  		inicialRececpcion = recibirMaterial(sku, bodegaRecepcion, bodegaPrincipal)
  		inicialPulmon = recibirMaterial(sku, bodegaPulmon, bodegaPrincipal)
  		puts "--- Recibiendo sku " + sku + " Recepcion: " + inicialRececpcion.to_s + " Pulmon: " + inicialPulmon.to_s 
  	end

  	materias = Sku.where("grupoProyecto = ? AND tipo = ?"  , @GrupoProyecto , "Producto procesado")
  		materias.each do |row|
  		sku = row.sku	
  		inicialRececpcion = recibirMaterial(sku, bodegaRecepcion, bodegaPrincipal)
  		inicialPulmon = recibirMaterial(sku, bodegaPulmon, bodegaPrincipal)
  		puts "--- Recibiendo sku " + sku + " Recepcion: " + inicialRececpcion.to_s + " Pulmon: " + inicialPulmon.to_s 

  		ingrediente = Formula.where("sku = ?"  , sku)
 			ingrediente.each do |ing|
			skuMaterial = ing.skuIngerdiente	
			inicialRececpcion = recibirMaterial(skuMaterial, bodegaRecepcion, bodegaPrincipal)
  			inicialPulmon =recibirMaterial(skuMaterial, bodegaPulmon, bodegaPrincipal)
		puts "--- Recibiendo sku " + skuMaterial + " Recepcion: " + inicialRececpcion.to_s + " Pulmon: " + inicialPulmon.to_s 

 		end	

  	end

  end	


  def self.recibirMaterial( sku , almacenRecepcion , bodegaMateriasPrimas)
  		  		
  		stock = checkStock(sku ,almacenRecepcion) 
		stockInicial = stock	
  		moverInventario(sku, stock, almacenRecepcion, bodegaMateriasPrimas)

  		return stockInicial
  end 	





  def self.moveProducts(products , cantidad , destino)
	
  	if cantidad.nil? | products.nil? | cantidad==0
  		return
  	end	
  	for counter in 0..cantidad-1
  		id = products[counter]["_id"]
  		moverStock(id , destino)
  	end
  end	

end
