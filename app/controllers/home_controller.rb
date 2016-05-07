class HomeController < ApplicationController
	include ApplicationHelper
  include InventarioHelper
  include 
  def index


    #almacen id example (79 producto)= 571262aaa980ba030058a1f3
    #producto id 571262aaa980ba030058a23c
    #id orden de compra 571b745e79749603006e3eb2

    #@show= obtenerTransaccion('1234')

  	#@show = getAlmacenes()

  	#@show = getSKUWithStock('571262aaa980ba030058a1f3')
  	#@show = getCuentaFabrica()
  	#@show = getStock('571262aaa980ba030058a1f3' , 49 )
    #@show = moverStock( '571262aaa980ba030058a23c', '571262aaa980ba030058a1f1' )
  	

    #@show = anularOrdenDeCompra("571c0c42d7edb6030071f243" , "prueba")
  	#@show = getSKUWithStock('571262aaa980ba030058a23d')
  	#@show= getCuentaFabrica()
    #@show= transferir(10 , "571262c3a980ba030058ab5d", "571262aea980ba030058a5d8")
    #@show = producirStock("8","572283e304c78e0300ce3ee2", 10 )
    #@show = getStock('571262aaa980ba030058a1f2' , 8  , 100)  

    #@show = despacharStock('57251793de2f4b0300559bbb' , 'direccion' , 1313 , "571507225bfa0a030038ab75")
  	#@show = getSKUWithStock('571262aaa980ba030058a1f1')
  	#@show = getSKUWithStock('571262aaa980ba030058a23d')
    #@show = getSKUWithStock('571262aaa980ba030058a1f2')
  	#@show= getCuentaFabrica()
    #@show= transferir(10 , "571262c3a980ba030058ab5d", "571262aea980ba030058a5d8")
    #@show = producirStock("8","572283e304c78e0300ce3ee2", 10 )
    #@show = getStock('571262aaa980ba030058a1f2' , 8  , 100)  
    #@show = getStock('571262aaa980ba030058a1f2' , 49 )  

    #@show = moverStock( '571262b6a980ba030058a7db', '571262aaa980ba030058a1f3' )
    #@show = moverStock( '57251793de2f4b0300559bbb', '571262aaa980ba030058a1f2' )#mover al despacho
    #@moverStock = moverStockBodega( '571262aaa980ba030058a23c', '571262aaa980ba030058a1f3' )
   # @show = moverStockBodega( '572bc4190c090d030024f2b4', '571262aaa980ba030058a1f1' , '572938439fda6e0300480f45', 1313)
    #@show = obtenerCartola(1429832246 , 1461454686, '571262c3a980ba030058ab5d')
    #@show = obtenerTransaccion('1234')
    #@show = obtenerCuenta('571262c3a980ba030058ab5d')
    #@show = obtenerCuenta('571262c3a980ba030058ab5d')
    #@show = recepcionarOrdenDeCompra('57270b94ba0c0f0300c51bef')
    #@show = obtenerOrdenDeCompra('5716baedb3eeeb0300a33409')
    #@show = rechazarOrdenDeCompra('57128e450606410300c3fbeb' , "no hay tiempo")
    #@show = obtenerFactura('571b745e79749603006e3eb2')  	
    #@show = emitirFactura('57270b94ba0c0f0300c51bef') 
    #@show = despacharFTP(14,40,"rerae",7413,"5727c26a4c0ce00300927f5e") # verSiEnviar('572e0be91a58ba03003efa37') 
    @show = vaciarStockBodegaChica()
  end

  def bodegas
    require 'json'
    @almacenesInfo = JSON.parse(getAlmacenes())
    totalspace = @almacenesInfo[0]["totalSpace"]
    totalspace = @almacenesInfo[0]["usedSpace"]
   
  
  end
end
