class HomeController < ApplicationController
	include ApplicationHelper
 
  def index


  	#almacen id example (79 producto)= 571262aaa980ba030058a1f3
    #producto id 571262aaa980ba030058a23c
    #id orden de compra 571b745e79749603006e3eb2
  	#@show = getAlmacenes()
  	#@show = getSKUWithStock('571262aaa980ba030058a1f3')
  	#@show = getCuentaFabrica()
  	#@show = getStock('571262aaa980ba030058a1f3' , 49 )  
    #@show = moverStock( '571262aaa980ba030058a23c', '571262aaa980ba030058a1f3' )
    #@show = moverStockBodega( '571262aaa980ba030058a23c', '571262aaa980ba030058a1f3' )
    #@show = obtenerCartola(1429832246 , 1461454686, '571262c3a980ba030058ab5d')
    #@show = obtenerTransaccion('1234')
    @show = obtenerCuenta('571262c3a980ba030058ab5d')
    #@show = obtenerCuenta('571262c3a980ba030058ab5d')
    #@show = recepcionarOrdenDeCompra('571b745e79749603006e3eb2')
    #@show = obtenerOrdenDeCompra('571b745e79749603006e3eb2')
    #@show = rechazarOrdenDeCompra('57128e450606410300c3fbeb' , "no hay tiempo")
    # @show = obtenerFactura('571b745e79749603006e3eb2')  	

  end
end
