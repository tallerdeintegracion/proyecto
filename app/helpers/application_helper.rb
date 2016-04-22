module ApplicationHelper

#Clave Bodega: GKTSVmI778e8Mjg

	

	def findKeys
		key = 'GKTSVmI778e8Mjg'
		return key
	end
	def bodegaBaseUrl
		return 'http://integracion-2016-dev.herokuapp.com'
	end

	def getAlmacenes

		path ='/bodega/almacenes'
		String toEncode = "GET" 
		url =bodegaBaseUrl+path
        authHeader = encodeHmac(toEncode)    
        data =  httpRequest(url , authHeader)
        return  data
	end



	def getSKUWithStock(almacenId)
	
		path ='/bodega/skusWithStock'
		url =bodegaBaseUrl+path+"?"+"almacenId="+almacenId
		String toEncode = "GET"+almacenId 
        authHeader = encodeHmac(toEncode)
        data =  httpRequest(url, authHeader)
        return  data

	end

	def getCuentaFabrica()

		path ='/bodega/fabrica/getCuenta'
		String toEncode = "GET"
		url =bodegaBaseUrl+path
        authHeader = encodeHmac(toEncode)
        data =  httpRequest(url, authHeader)
        return  data

	end



	def httpRequest( url, authHeader)
		require 'net/http'
		require 'uri'
		headers = {'Authorization' => authHeader , 'Content-Type' => 'application/json'}
        uri = URI.parse(url)        
        request = Net::HTTP::Get.new(uri, headers)
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
