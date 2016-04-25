class HomeController < ApplicationController
	include ApplicationHelper
 
  def index


  	#almacen id example (79 producto)= 571262aaa980ba030058a1f3
    #producto id 571262aaa980ba030058a23c
  	#@show = getAlmacenes()
  	#@show = getSKUWithStock('571262aaa980ba030058a1f3')
  	#@show = getCuentaFabrica()
  	#@show = getStock('571262aaa980ba030058a1f3' , 49 )  
    #@show = moverStock( '571262aaa980ba030058a23c', '571262aaa980ba030058a1f3' )
    #@show = moverStockBodega( '571262aaa980ba030058a23c', '571262aaa980ba030058a1f3' )
    #@show = obtenerCartola(1429832246 , 1461454686, '571262c3a980ba030058ab5d')
    #@show = obtenerTransaccion('1234')
    @show = obtenerCuenta('571262c3a980ba030058ab5d')
    @show = "ejemplo";
  	
  end
end
