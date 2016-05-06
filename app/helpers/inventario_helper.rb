module InventarioHelper
  
  #include  'ApplicationHelper'  #la clase que lo llama debería tener acceso a esto, no desde aquí


  def verSiEnviar(idFactura)
    sku = OC.find_by(factura: idFactura)["sku"]
    idOC = OC.find_by(factura: idFactura)["oc"]
#   return false

    despacharOC(idOC) 
  end
  
  def despacharOC(idOC)
    ## Pega de benja    
    require 'json'
    #puts "oc cantidad: "+ oc[0]['cantidad'].to_s+ " . oc sku: "+ oc[0]['sku'].to_s+"\n"
  oc = JSON.parse(obtenerOrdenDeCompra(idOC))
  if oc.nil?
      return false
  end    
  sku = oc[0]['sku'].to_s
  cantidad = oc[0]['cantidad'].to_i
  canal = oc[0]['canal'].to_s
  precio = oc[0]['precioUnitario'].to_i
  id_cliente = oc[0]['cliente'].to_s
  puts "despachar sku " + sku + " cantidad " + cantidad.to_s + " al precio " + precio.to_s + " del canal " + canal +"\n"

  #return true

  #Primero se ve si hay productos para despachar. Si no están todos los requeridos no despacha:
  result = JSON.parse(getSKUWithStock('571262aaa980ba030058a1f2'))#bodega despacho  
  if result.nil?
    puts "no hay productos para despachar, por eso entrega nulo es stock" + "\n" 
    return false #no hay productos para despachar, por eso entrega nulo
  end 

  for counter in 0..(result.length-1)
    actualSku =result[counter]['_id'].to_s
    if(sku == actualSku) #si hay del sku requerido para despachar, se ve la cantidad
      if result[counter]['total'].to_i < cantidad
        puts "no hay cantidad necesaria para despachar" + "\n" 
        return false #no hay cantidad necesaria para despachar
      else #se continua y despacha más abajo
        break
      end
    end
  end

  #se diferencia del despacho según el canal  
  if canal == "b2b"
    
    fila_grupo = Grupo.find_by(idGrupo: id_cliente)  
    #oc_db.update(estados: 'creada')
    if fila_grupo.nil? #si es nula se crea más abajo     
      puts "no se sabe de quién es la oc" + "\n" 
      return false #no se sabe de quién es la oc
    end   
    grupoDestino = fila_grupo.nGrupo.to_s
    almacenId = fila_grupo.idAlmacen.to_s

    puts "grupo destino es el " + grupoDestino + " y el almacén tiene id " + almacenId.to_s + "\n" 

    cantidad_fija = cantidad
    movidas = 0
    while (cantidad.to_i > 0) do
        productos = JSON.parse(getStock('571262aaa980ba030058a1f2' , sku.to_s ) )#bodega de despacho
        limite = 0
      if productos.nil?
        break
      else
        
        if cantidad.to_i > productos.length
          limite = productos.length
        else
          limite = cantidad.to_i
        end   
        puts productos.length.to_s + " productos recibidos. Cantidad a mover " + cantidad.to_s + "\n"
        movidas = movidas + limite  
        for counter in 0..(limite-1)#(cantidad.to_i-1) #se mueven los productos solicitados, que sabemos es menor que lo que hay en la bodega despacho
            moverStockBodega( productos[counter]['_id'].to_s,  almacenId, idOC, precio)
        end
      end
      cantidad = (cantidad.to_i - limite)
    end  
    puts "Se movieron " + movidas.to_s + " de " + cantidad_fija.to_s + " pedidas de la bodega despacho a la de recepción del grupo " + grupoDestino.to_s + "\n"  
    
  elsif canal == "ftp"

  end

  return true

  end

def dejarStockEnDespacho(sku_a_mover)
  require 'json'
    #puts "oc cantidad: "+ oc[0]['cantidad'].to_s+ " . oc sku: "+ oc[0]['sku'].to_s+"\n"
  arreglo = JSON.parse(getSKUWithStock("571262aaa980ba030058a1f3"))#bodegaDespacho
  if arreglo.nil?
    puts "no hay stock" + "\n"  
      return false
  end  
  array = []  
#=begin
  for counter in 0..(arreglo.length-1)
    array.push(arreglo[counter]['_id'].to_s)    
  end
#=end
  #puts array[0] + "      ZZZZZZ   " + array[1] + "   " + array[2] + "\n"

  array.each do |sku| 
    productos = JSON.parse(getStock('571262aaa980ba030058a1f3' , sku.to_s ) )
    if productos.nil?
       puts "siempre nulo " + "\n" 
    else
      if sku_a_mover.to_s == sku
        for counter in 0..(productos.length-1) 
          moverStock( productos[counter]['_id'].to_s, '571262aaa980ba030058a1f2' )  #la mueve a la principal
          puts "se movió un producto" + "\n" 
        end 
        break
      end
    end
  end
  return true
  end


  def moverInventario(sku, cantidad, almacenOrigen, almacenDestino)
    
    ## Falta confirmar que exista el stock necesario
    
    ## Ejecutamos el código para mover la cantidad necesaria de 200 en 200
    total = 0
    if cantidad > 100
      total = moverInventario(sku,cantidad-100,almacenOrigen,almacenDestino)
      cantidad = 100
    end
    
      
    ids = JSON.parse(getStock(almacenOrigen , sku , cantidad))
    counter = 0
    while counter < cantidad
      begin
        result = JSON.parse(moverStock(ids[counter]["_id"], almacenDestino))    
        if result["message"]
          puts "No se movio, intentando nuevamente"
          ids = JSON.parse(getStock(almacenOrigen , sku , cantidad-counter))
          counter = counter-1
        end
      rescue => ex
        puts "No se movio, intentando nuevamente"
        ids = JSON.parse(getStock(almacenOrigen , sku , cantidad-counter))
        counter = counter-1
      end
      puts "Movido correctamente, N= "+ counter.to_s
      counter = counter+1
    end
    return total+counter
#    moverStock(ProductId, almacenDestino)
  end
end
