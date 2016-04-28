class InventarioController < ApplicationController
 	
 	
 	extend	ApplicationHelper
 	

#6	Crema	Producto procesado	3	Lts	  2,402 	  30 	0.979
#8	Trigo	Materia prima	3	Kg	  1,313 	  100 	0.784
#14	Cebada	Materia prima	3	Kg	  696 	  1,750 	1.355
#31	Lana	Materia prima	3	Mts	  1,434 	  960 	3.449
#49	Leche Descremada	Producto procesado	3	Lts	  1,459 	  200 	4.281
#55	Galletas Integrales	Producto procesado	3	Kg	  2,284 	  950 	3.955

  
  def self.run
  @returnPoint = 200
  @loteSku8 = 100
  bodegaPrincipal = "571262aaa980ba030058a1f3"
  puts "Inicia revicion de inventario "
  checkMateriasPrimas(bodegaPrincipal)
  end

  def self.checkStock(sku , bodega)
  	require 'json'
  	result = JSON.parse(getSKUWithStock(bodega))
  	stock =0
	for counter in 0..(result.length-1)
		actualSku =result[counter]['_id'].to_i
		actualTotal =result[counter]['total'].to_i
		if(sku == actualSku)
			stock = actualTotal 
		end
	end
	puts "Actualmente hay " + stock.to_s+ " del sku "+ sku.to_s 
	return actualTotal
  		
  end


  def self.checkMateriasPrimas(bodega)

  sku = "8"	
  costeTrigo =1313
  tamañoLote = 100


  stock = checkStock(sku, bodega)
  lotes = calcularLotes(stock, sku)
  	if lotes > 0
  	producirMateriaPrima(sku , lotes  , tamañoLote ,costeTrigo)
	end


  end


  def self.calcularLotes(stock , sku )

  	tMedioProd = 4


  	difTime = Production.timeStampDiference(sku)
  	lastProd = Production.lastProductionQuantity(sku)

  	if tMedioProd < difTime
  		newReturnPoint = @returnPoint - lastProd
  	else
  		newReturnPoint = @returnPoint
  	end
  	 
  	lotes = (newReturnPoint-stock)/@loteSku8

  	p "Se deveven producir  " + lotes.to_s

  	if lotes < 1 
  		return 0
  	else
  		return lotes
  	end

  
  
  end



  def self.producirMateriaPrima(sku , lotes ,tamañoLote , costoUnitario)

  	#cuentaFabrica = getCuentaFabrica.cuentaId.to_s
  	#cuentaGrupo = "571262c3a980ba030058ab5d"
  	#monto= lotes*(tamañoLote*costoUnitario)


  	
  end

  
#572283e304c78e0300ce3ee2"


end
