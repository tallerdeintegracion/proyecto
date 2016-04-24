module ApplicationHelper

#Clave Bodega: GKTSVmI778e8Mjg

	

	def findKeys
		key = 'GKTSVmI778e8Mjg'
		return key
	end
	def bodegaBaseUrl
		return 'http://integracion-2016-dev.herokuapp.com/bodega'
	end

	def getAlmacenes

		path ='/almacenes'
		String toEncode = "GET" 
		url =bodegaBaseUrl+path
        authHeader = encodeHmac(toEncode)    
        data =  httpRequest(url , authHeader, "GET")
        return  data
	end



	def getSKUWithStock(almacenId)
	
		path ='/skusWithStock'
		url =bodegaBaseUrl+path+"?"+"almacenId="+almacenId
		String toEncode = "GET"+almacenId 
        authHeader = encodeHmac(toEncode)
        data =  httpRequest(url, authHeader,"GET")
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
        data =  httpRequest(url, authHeader,"GET")
        return  data

	end




	def moverStock(productoId , almacenId)
		path ='/moveStock'
		url =bodegaBaseUrl+path+"?"+"productoId="+productoId+'&'+"almacenId="+almacenId
		#render :text => url
		String toEncode = "POST"+productoId+almacenId
		#render :text => toEncode
        authHeader = encodeHmac(toEncode)
        render :text => authHeader
        data =  httpRequest(url, authHeader,"POST")
        return  data
	end	

	def moverStockBodega(productoId , almacenId)

		path ='/moveStockBodega'
		url =bodegaBaseUrl+path+"?"+"productoId="+productoId+'&'+"almacenId="+almacenId
		#render :text => url
		String toEncode = "POST"+productoId+almacenId
		
        authHeader = encodeHmac(toEncode)
        #render :text => authHeader
        data =  httpRequest(url, authHeader,"POST")
        return  data
	end	

    #INTEGRACION grupo3:4duJdOkzEf2a6eycwDXgM5MzU9o=

	def getCuentaFabrica()

		path ='/fabrica/getCuenta'
		String toEncode = "GET"
		url =bodegaBaseUrl+path
        authHeader = encodeHmac(toEncode)
        data =  httpRequest(url, authHeader,"GET" )
        return  data

	end



	def httpRequest( url, authHeader, type )
		require 'net/http'
		require 'uri'
		headers = {'Authorization' => authHeader , 'Content-Type' => 'application/json'}
        uri = URI.parse(url)    
        if type=="GET"
        request = Net::HTTP::Get.new(uri, headers)
        elsif type=="POST"
        request = Net::HTTP::Post.new(uri, headers)
        end	
        response = Net::HTTP.new(uri.host, 80).start {|http| http.request(request) }
    	data = response.body

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
