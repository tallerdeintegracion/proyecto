class HomeController < ApplicationController
	include ApplicationHelper
 
  def index


  	#Etaba probando  =)
  	#almacen id example (79 producto)= 571262aaa980ba030058a1f3
    #producto id 571262aaa980ba030058a23c
  	#@show = getAlmacenes()
  	@show = getSKUWithStock('571262aaa980ba030058a1f3')
  	#@show = getCuentaFabrica()
  	#@show = getStock('571262aaa980ba030058a1f3' , 49 )
    #@show = moverStock( '571262aaa980ba030058a23c', '571262aaa980ba030058a1f1' )
  	
  end

  def bodegas
    require 'json'
    @almacenesInfo = JSON.parse(getAlmacenes())

    totalspace = @almacenesInfo[0]["totalSpace"]
    totalspace = @almacenesInfo[0]["usedSpace"]
   
  
  end
end
