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
		return 0 
	end	

	return prod.cantidad

end	

def self.updateProduction(cantidad , sku)

	
		p "creating new element"
		prod = Production.new	
		prod.sku = sku
		prod.cantidad =cantidad
		prod.disponible= Time.now
		prod.save
		p Production.find_by(sku)
	
end




end
