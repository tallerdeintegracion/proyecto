module ApplicationHelper

#Clave Bodega: GKTSVmI778e8Mjg

	

	



	def bodegaBaseUrl
		return 'http://integracion-2016-dev.herokuapp.com/bodega'
	end
	def bancoBaseUrl
		return 'http://mare.ing.puc.cl/banco'
	end
	def ocBaseUrl
		return 'http://mare.ing.puc.cl/oc'
	end
	def facturaBaseUrl
		return 'http://mare.ing.puc.cl/facturas'
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

	def getStock(almacenId , sku , limit = 100)
	
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

	def moverStockBodega(productoId , almacenId)
		path ='/moveStockBodega'
		url =bodegaBaseUrl+path
		String toEncode = "POST"+productoId+almacenId
        authHeader = encodeHmac(toEncode)
        params = {'productoId' => productoId, 'almacenId' => almacenId}
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
	#
	#
	#
	#
	#
	#
	#
	#

	def crearOrdenDeCompra(canal , cantidad , sku , proveedor , precio , notas)
		path ='/crear'
		url =ocBaseUrl+path
		params={ "canal" => canal , 
				"cantidad" => cantidad,
				"sku" => sku,
				"proveedor" => proveedor,
				"precio" => precio,
				"notas" => notas
				}

		#data =  httpPostRequest(url , nil, params)
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
		params={'id'=> "571262c3a980ba030058ab5d",'motivo'=> "abc"	}
		data =  httpDeleteRequest(url , nil, params)
		

	end

	def obtenerOrdenDeCompra(idOrdenDeCompra)
		path ='/obtener/'+idOrdenDeCompra
		url =ocBaseUrl+path
        data =  httpGetRequest(url , nil )
        return  data

	end

	#Sistema facturas
	#
	#
	#
	#
	#
	#
	#
	#
	#
	def emitirFactura (idOrdenDeCompra )
		path ='/'
		url =facturaBaseUrl+path
		params={ "oc" => idOrdenDeCompra }
		data =  httpPutRequest(url , nil, params)
		return  data		

	end
	def obtenerFactura(idfactura)

		path ='/'+idfactura
		url =facturaBaseUrl+path
        data =  httpGetRequest(url , nil )
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



	def httpDeleteRequest( url, authHeader ,params)
		
		require 'net/http'
		require 'uri'
		if authHeader.nil?
		headers = {'Content-Type' => 'application/json'}
		else
		headers = {'Authorization' => authHeader , 'Content-Type' => 'application/json'}
		end	
        uri = URI.parse(url)
        http = Net::HTTP::Delete.new(uri.host)
        http.set_form_data(params)
        if params.nil?
		response = http.delete(uri.path)
		else
		response = http.delete(uri.path)	  
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
        response = Net::HTTP.new(uri.host, uri.port).start {|http| http.request(request) }
    	data = response.body
	end



	def findKeys
		key = 'GKTSVmI778e8Mjg'
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








end
