class HomeController < ApplicationController
	include ApplicationHelper
 
  def index


    #almacen id example (79 producto)= 571262aaa980ba030058a1f3
    #producto id 571262aaa980ba030058a23c
    #id orden de compra 571b745e79749603006e3eb2

    #@show= obtenerTransaccion('1234')

  	#@show = getAlmacenes()
  	#@show = getSKUWithStock('571262aaa980ba030058a1f3')
  	#@getCuentaFabrica= getCuentaFabrica()
    @show = getStock('571262aaa980ba030058a1f3' , 49 ,10)  
    #@show = moverStock( '571262aaa980ba030058a23c', '571262aaa980ba030058a1f3' )
    #@moverStock = moverStockBodega( '571262aaa980ba030058a23c', '571262aaa980ba030058a1f3' )
    #@show = obtenerCartola(1429832246 , 1461454686, '571262c3a980ba030058ab5d')
    #@obtenerTransaccion = obtenerTransaccion('1234')
    #@obtenerCuenta = obtenerCuenta('571262c3a980ba030058ab5d')
    #@recepcionarOrdenDeCompra = recepcionarOrdenDeCompra('571b745e79749603006e3eb2')
    #@obtenerOrdenDeCompra = obtenerOrdenDeCompra('571b745e79749603006e3eb2')
    #@rechazarOrdenDeCompra = rechazarOrdenDeCompra('57128e450606410300c3fbeb' , "no hay tiempo")
    #@show = anularOrdenDeCompra('57128e450606410300c3fbeb' , "no hay tiempo")
    #@show = obtenerFactura('571b745e79749603006e3eb2')
    # @show = crearOrdenDeCompra('Internacional', 100 , 2, '84378234jhgd36', 1000,'soy una notas')  


  end
end
