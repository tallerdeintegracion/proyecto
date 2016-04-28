class Production < ActiveRecord::Base

def self.timeStampDiference(sku)


	prod = Production.find_by(sku: sku)
	if prod.nil?
		return 900000000 ##numero suficientemente grande
	end	
	time = Time.now.to_i
	prodTime = prod.timeStamp
	
	retorno = (prodTime-time)/3600
	return retorno
end

def self.lastProductionQuantity(sku)

	prod = Production.find_by(sku: sku)
	if prod.nil?
		return 0 ##numero suficientemente grande
	end	

	return prod.cantidad

end	

def updateProduccion(cantidad , sku)
	prod = Production.find_by(sku: sku)
	if prod.nil?
		prod.timeStamp=Time.now.to_i
		prod.cantidad = cantidad
	else
		prod = Production.new	
		prod.sku = sku
		prod.cantidad =cantidad
		prod.timeStamp= Time.now.to_i
	end
end
end
