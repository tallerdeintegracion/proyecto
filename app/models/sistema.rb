class Sistema < ActiveRecord::Base
	## Ambiente Actual: prod
	## l461 Probablemente hay qye cambiar el token de spree
	def idGrupo
		return  "572aac69bdb6d403005fb044" #"571262b8a980ba030058ab51" #
	end
	def idBanco
		return "572aac69bdb6d403005fb050" #"571262c3a980ba030058ab5d" #
	end
	def bodegaBaseUrl
		return 'http://integracion-2016-prod.herokuapp.com/bodega' #'http://integracion-2016-dev.herokuapp.com/bodega' #
	end
	def bancoBaseUrl
		return 'http://moto.ing.puc.cl/banco' # 'http://mare.ing.puc.cl/banco' #
	end
	def ocBaseUrl
		return 'http://moto.ing.puc.cl/oc' #'http://mare.ing.puc.cl/oc' #
	end
	def facturaBaseUrl
		return 'http://moto.ing.puc.cl/facturas' #'http://mare.ing.puc.cl/facturas' #
	end



	## Metodos bodega###
	# -getAlmacenes
	# -getSKUWithStock
	# -getStock
	# -moverStock
	# -moverStockBodega
	# - producir(no implementado)
	# - Despachar(no implementado) 
	# -getCuentaFabrica

	def despacharStock (productId , direccion , precio , idOrdenDeCompra) 
	
		path ='/stock'
		url =bodegaBaseUrl+path
		String toEncode = "DELETE"  + productId + direccion + precio.to_s + idOrdenDeCompra
		authHeader = encodeHmac(toEncode)  

		params={
				'productoId'=> productId , 
				'direccion'=> direccion, 
				'precio' =>	precio, 
				'oc' => idOrdenDeCompra 
				}

		data =  httpDeleteRequest(url , authHeader, params)
        return  data
		


	end 	
	def getAlmacenes

		path ='/almacenes'
		String toEncode = "GET" 
		url =bodegaBaseUrl+path
        authHeader = encodeHmac(toEncode)    
        data =  httpGetRequest(url , authHeader)
        return  data
	end

	def getSKUWithStock(almacenId)
	
		path ='/skusWithStock'
		url =bodegaBaseUrl+path+"?"+"almacenId="+almacenId
		String toEncode = "GET"+almacenId 
        authHeader = encodeHmac(toEncode)
        data =  httpGetRequest(url , authHeader)
        return  data

	end

	def getStockSpree(urlReal)
   
	    url = urlReal + "/spree/api/v1/stock_locations/1/stock_items"
	    #X-Spree-Token header
	    authHeader = "55556cabf397aebfd4ecffa7676f332b3fe2f6cbdbfd7c00"
	    data =  httpGetRequestSpree(url , authHeader)	
	    return  data

  	end

  	def putStockSpree(urlReal, cantidad, producto)
  		require 'json'

		url = urlReal + "/spree/api/v1/stock_locations/1/stock_items/" + producto.to_s

		puts  " se envia a la url " + url
		#X-Spree-Token header
		authHeader = '55556cabf397aebfd4ecffa7676f332b3fe2f6cbdbfd7c00'
		params = {	'stock_item' => 
					{'count_on_hand' => cantidad , 
					'force' => true 
					} 
				}		
		data =  httpPutRequestSpree(url , authHeader, params )
		return  data
	end

	def getStock(almacenId , sku , limit )
	
		if limit > 200
			return
		end 
		path ='/stock'
		url =bodegaBaseUrl+path+"?"+"almacenId="+almacenId+'&'+"sku="+sku.to_s+"&limit="+limit.to_s
		String toEncode = "GET"+almacenId+sku.to_s
        authHeader = encodeHmac(toEncode)
        data =  httpGetRequest(url , authHeader)
        return  data

	end

	def moverStock(productoId , almacenId)
		path ='/moveStock'
		url =bodegaBaseUrl+path
		String toEncode = "POST"+productoId+almacenId

        authHeader = encodeHmac(toEncode)
        params = {'productoId' => productoId, 'almacenId' => almacenId}
        data =  httpPostRequest(url , authHeader, params)

        return  data
	end	

	def moverStockBodega(productoId , almacenId, idOC, precio)
		path ='/moveStockBodega'
		url =bodegaBaseUrl+path
		String toEncode = "POST"+productoId+almacenId
        authHeader = encodeHmac(toEncode)
        params = {'productoId' => productoId, 'almacenId' => almacenId, 'oc' => idOC, 'precio' => precio}
        data =  httpPostRequest(url , authHeader, params)
        return  data
	end	

	def producirStock(sku , trxId , cantidad)
		path ='/fabrica/fabricar'
		url =bodegaBaseUrl+path
		params = { 
			"sku" => sku,
			"trxId" => trxId,
			"cantidad" => cantidad
		}
		String toEncode = "PUT"+sku+cantidad.to_s+trxId
		authHeader = encodeHmac(toEncode)
		data =  httpPutRequest(url , authHeader, params)
		return  data
	end	


	def getCuentaFabrica()

		path ='/fabrica/getCuenta'
		String toEncode = "GET"
		url =bodegaBaseUrl+path
        authHeader = encodeHmac(toEncode)
        data =  httpGetRequest(url , authHeader)
        return  data

	end

	# Banco#
	# => obtenertransaccion
	# => obtener cartola
	# => obtener cuenta
	# => transferir

	def transferir(monto , origen , destino  )

		path ='/trx'
		url =bancoBaseUrl+path
		params = { 
			"monto" => monto,
			"origen" => origen,
			"destino" => destino
		}

		data =  httpPutRequest(url , nil, params)
		return  data

	end

	def obtenerTransaccion(id)
		path ='/trx/'+id
		url =bancoBaseUrl+path
		data =  httpGetRequest(url ,nil)
        return  data

	end
	def obtenerCartola(fechaInicio , fechaFin, id)

		path ='/cartola'
		url =bancoBaseUrl+path
		params = {"fechaInicio"=> fechaInicio,"fechaFin"=> fechaFin,"id"=> id}
		data =  httpPostRequest(url , nil, params)
		return  data
	end
	def obtenerCuenta(id)
		path ='/cuenta/'+id
		url =bancoBaseUrl+path
		data =  httpGetRequest(url ,nil)
        return  data
	
	end

	#orden de compra

	
	def crearOrdenDeCompra(canal , cantidad , sku , cliente, proveedor , precioUnitario , fechaEntrega , notas)
		path ='/crear'
		url =ocBaseUrl+path
		params={ "canal" => canal , 
				"cantidad" => cantidad,
				"sku" => sku,
				"cliente" => proveedor,
				"proveedor" => proveedor,
				"precioUnitario" =>  precioUnitario,
				"fechaEntrega" => fechaEntrega,
				"notas" => notas
				}

		data =  httpPutRequest(url , nil, params)
		return  data

	end

	def recepcionarOrdenDeCompra(idOrdenDeCompra)
		path ='/recepcionar/'+idOrdenDeCompra
		url =ocBaseUrl+path
		params={ "id" => idOrdenDeCompra }
		data =  httpPostRequest(url , nil, params)
		return  data
	
	end
	def rechazarOrdenDeCompra(idOrdenDeCompra, motivo)
		path ='/rechazar/'+idOrdenDeCompra
		url =ocBaseUrl+path
		params={ "id" => idOrdenDeCompra , "rechazo" => motivo}
		data =  httpPostRequest(url , nil, params)
		return  data
	end

	def anularOrdenDeCompra(idOrdenDeCompra , motivo)

		path ='/anular/'+idOrdenDeCompra
		url =ocBaseUrl+path
		params={'id'=> idOrdenDeCompra ,'anulacion'=> motivo	}
		data =  httpDeleteRequest(url , nil, params)
		

	end

	def obtenerOrdenDeCompra(idOrdenDeCompra)
		path ='/obtener/'+idOrdenDeCompra
		url =ocBaseUrl+path
        data =  httpGetRequest(url , nil )
        return  data

	end

	#
	def emitirFactura (idOrdenDeCompra )
		path ='/'
		url =facturaBaseUrl+path
		params={ "oc" => idOrdenDeCompra }
		data =  httpPutRequest(url , nil, params)
		return  data		

	end
	def emitirBoleta (cliente,total)
		path ='/boleta'
		url =facturaBaseUrl+path
		params={ "proveedor" => idGrupo, "cliente" => cliente, "total" => total }
		data =  httpPutRequest(url , nil, params)
		return  data		

	end
	def obtenerFactura(idfactura)

		path ='/'+idfactura
		url =facturaBaseUrl+path
        data =  httpGetRequest(url , nil )
        return  data
	end
	def facturaPagada(idfactura)

		path ='/pay'
		url =facturaBaseUrl+path
		params = { "id" => idfactura }
        data =  httpPostRequest(url , nil, params )
        return  data
	end


	def httpPostRequest( url, authHeader ,params)
		require 'net/http'
		require 'uri'
		if authHeader.nil?
			headers = {'Content-Type' => 'application/json'}
		else
			headers = {'Authorization' => authHeader , 'Content-Type' => 'application/json'}
		end	

        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)

        if params.nil?
		response = http.post(uri.path,'{}', headers)
		else
		response = http.post(uri.path, params.to_json, headers)	 
		end	

    	data = response.body

	end

	def httpPutRequest( url, authHeader ,params)
		require 'net/http'
		require 'uri'
		require 'httparty'
		
		if authHeader.nil?
			headers = {"Content-Type" => "application/json"}
		else
			headers = {'Authorization' => authHeader , 'Content-Type' => 'application/json'}
		end	
        
        uri = URI.parse(url)
        http = Net::HTTP::new(uri.host, uri.port)
        if params.nil?
			#response = HTTParty.put(url, :headers => headers)
		else
			response = HTTParty.put(url ,
				:headers =>  headers,
				:body => params.to_json	
				)
		end	
    	data =  response.body
    	return data
	end

	def httpPutRequestSpree( url, authHeader ,params)
		require 'net/http'
		require 'uri'
		require 'httparty'
		
		headers = {'X-Spree-Token' => authHeader , 'Content-Type' => 'application/json'}	
       
		puts authHeader
        uri = URI.parse(url)
        http = Net::HTTP::new(uri.host, uri.port)

        if params.nil?
			#response = HTTParty.put(url, :headers => headers)
		else
			puts params.to_json
			response = HTTParty.put(url ,
				:headers =>  headers,
				:body => params.to_json	
				)
		end	
		puts "saliendoo al hTTp party "	+ response.to_s	

    	data =  response.body
    	return data
	end

	def valid_json?(json)
  		begin
    	JSON.parse(json)
    	return true
  		rescue JSON::ParserError => e
   		return false
  		end
	end

	def httpDeleteRequest( url, authHeader ,params)
		
		require 'net/http'
		require 'uri'
		require 'httparty'

		if authHeader.nil?
		headers = {'Content-Type' => 'application/json'}
		else
		headers = {'Authorization' => authHeader , 'Content-Type' => 'application/json'}
		end	
		uri = URI.parse(url)
        http = Net::HTTP::new(uri.host, uri.port)
        
        if params.nil?
		#response = http.delete(uri.path)
		else
		response = HTTParty.delete(url ,
				:headers =>  headers,
				:body => params.to_json	
				)	  
		end	
    	data = response.body

	end

	def httpGetRequest( url, authHeader)
		require 'net/http'
		require 'uri'
		
		if authHeader.nil?
			headers = {'Content-Type' => 'application/json'}
		else
			headers = {'Authorization' => authHeader , 'Content-Type' => 'application/json'}
		end	
        uri = URI.parse(url)    
        request = Net::HTTP::Get.new(uri, headers)
       	
       	begin 
       	 	response = Net::HTTP.new(uri.host, uri.port).start {|http| http.request(request) } 
       	
       	rescue Errno::ETIMEDOUT  
       	 	puts "--- Time out de la conexion" 
        	
    	end  
    	if response.nil?
    		return nil
    	end	
  
    	return data = response.body

	end

	def httpGetRequestSpree( url, authHeader)
		require 'net/http'
		require 'uri'
		
		headers = {'X-Spree-Token' => authHeader , 'Content-Type' => 'application/json'}
		
        uri = URI.parse(url)    
        request = Net::HTTP::Get.new(uri, headers)
       	
       	begin 
       	 	response = Net::HTTP.new(uri.host, uri.port).start {|http| http.request(request) } 
       	
       	rescue Errno::ETIMEDOUT  
       	 	puts "--- Time out de la conexion" 
        	
    	end  
    	if response.nil?
    		return nil
    	end	
  
    	return data = response.body

	end



	def findKeys
		
		key =  '6xMNP5uAUVjt' #'GKTSVmI778e8Mjg' # 
		return key
	end

	def encodeHmac(data )
		require 'base64'
		require 'cgi'
		require 'openssl'
		key = findKeys
		coded = Base64.encode64("#{OpenSSL::HMAC.digest('sha1',key, data)}")
		result ="INTEGRACION grupo3:"+coded

        return result
	end
	
	## Retorna la cantidad de stock de un SKU que se puede vender
	def getStockSKUDisponible(sku)

		intermedio = JSON.parse(getAlmacenes).select {|h1| h1['despacho'] == false && h1['pulmon'] == false && h1['recepcion'] == false }
		
		## Revisamos la bodega grande
        almacenGrande = intermedio.max_by { |quote| quote["totalSpace"].to_f }["_id"]

		inventario = JSON.parse(getSKUWithStock(almacenGrande))
    	cantidadJSON = inventario.find { |h1| h1["_id"] == sku }
    	cantidad = 0

		## Sumamos la cantidad que corresponde
    	if cantidadJSON != nil
    	  #puts " cantidad almacen grande " + cantidadJSON["total"]
    	  cantidad = cantidad + cantidadJSON["total"]
    	end

		## Revisamos la bodega chica
		#almacenChico = intermedio.min_by { |quote| quote["totalSpace"].to_f }["_id"]

    	#inventario1 = JSON.parse(getSKUWithStock(almacenChico))
    	#cantidadJSON1 = inventario1.find { |h1| h1["_id"] == sku }

    	#inventario1 = JSON.parse(getSKUWithStock(almacenChico))
    	#cantidadJSON1 = inventario1.find { |h1| h1["_id"] == sku }

		## Sumamos la cantidad que corresponde
		#if cantidadJSON1 != nil
   	 	#  cantidad = cantidad + cantidadJSON1["total"]
    	#end

		## Restamos lo ya reservado
		skuDB = Sku.find_by(sku: sku)
		cantidad = cantidad - skuDB["reservado"]

		puts " cantidad disponible: " + cantidad.to_s
		return cantidad
	end

end
