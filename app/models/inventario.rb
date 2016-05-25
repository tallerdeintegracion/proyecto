class Inventario < ActiveRecord::Base

 #include  'ApplicationHelper'  #la clase que lo llama debería tener acceso a esto, no desde aquí


  def verSiEnviar(idFactura)
    Rails.logger.debug("debug:: seguimos en el despacho")
    idOC = Oc.find_by(factura: idFactura)["oc"]
    Rails.logger.debug("debug:: seguimos en el despacho")

#   return false


    despacharOC(idOC) 
  end
  
  def despacharOC(idOC)
    ## Pega de benja    
  sist = Sistema.new
    require 'json'
    #puts "oc cantidad: "+ oc[0]['cantidad'].to_s+ " . oc sku: "+ oc[0]['sku'].to_s+"\n"
  oc = JSON.parse(sist.obtenerOrdenDeCompra(idOC))
  if oc.nil?
      return false
  end    
  sku = oc[0]['sku'].to_s
  cantidad = oc[0]['cantidad'].to_i
  canal = oc[0]['canal'].to_s
  precio = oc[0]['precioUnitario'].to_i
  id_cliente = oc[0]['cliente'].to_s
  logead = "despachar sku " + sku + " cantidad " + cantidad.to_s + " al precio " + precio.to_s + " del canal " + canal +"\n"
  Rails.logger.debug("debug:: "+ logead)

  ## Obtiene el almacen grande
  intermedio = JSON.parse(sist.getAlmacenes).select {|h1| h1['despacho'] == false && h1['pulmon'] == false && h1['recepcion'] == false }
  almacenOrigen = intermedio.max_by { |quote| quote["totalSpace"].to_f }["_id"]

  cant = moverInventarioDespacho(sku, cantidad, almacenOrigen)
  Rails.logger.debug("debug:: movemos al despacho")

  if cant != cantidad
    return false
  end
  
  #se diferencia del despacho según el canal  
  if canal == "b2b"
    Rails.logger.debug("debug:: despacho es b2b")

    fila_grupo = Grupo.find_by(idGrupo: id_cliente)  
    #oc_db.update(estados: 'creada')
    if fila_grupo.nil? #si es nula se crea más abajo     
      puts "no se sabe de quién es la oc" + "\n" 
      return false #no se sabe de quién es la oc
    end   
    grupoDestino = fila_grupo.nGrupo.to_s
    almacenId = fila_grupo.idAlmacen.to_s

    puts "grupo destino es el " + grupoDestino + " y el almacén tiene id " + almacenId.to_s + "\n" 
    puts "Se despacha al cliente"

    variable = despacharCliente(sku,cantidad,almacenId,precio,idOC)
    ocDB = Oc.find_by(oc: idOC)
    ocDB.update(estados: "Despachada")

      Rails.logger.debug("debug::"+variable.to_s)
      
  elsif canal == "ftp"
    ## QUE CHUCHA ES DIRECCIÓN
    puts "Se despacha al ftp"
    direccion="estadireccion"
    despacharFTP(sku,cantidad,direccion,precio,idOC)
    ocDB = Oc.find_by(oc: idOC)
    puts "FTP despachado"
    ocDB.update(estados: "Despachada")
  end
  return true

  end
 def moverInventario(sku, cantidad, almacenOrigen,almacenDestino)
    sist = Sistema.new
    puts "Almacen de destino " + almacenDestino
    ## Falta confirmar que exista el stock necesario
    
    ## Ejecutamos el código para mover la cantidad necesaria de 100 en 100
    total = 0
    if cantidad > 100
      total = moverInventario(sku,cantidad-100,almacenOrigen,almacenDestino)
      cantidad = 100
    end
    
      
    ids = JSON.parse(getStock(almacenOrigen , sku , cantidad))
    counter = 0
    while counter < cantidad
      begin
        result = JSON.parse(sist.moverStock(ids[counter]["_id"], almacenDestino))    
        if result["message"]
          puts "No se movio, intentando nuevamente"
          ids = JSON.parse(sist.getStock(almacenOrigen , sku , cantidad-counter))
          counter = counter-1
        end
      rescue => ex
        puts "No se movio, intentando nuevamente"
        ids = JSON.parse(sist.getStock(almacenOrigen , sku , cantidad-counter))
        counter = counter-1
      end
      puts "Movido correctamente, N= "+ counter.to_s
      skuDB = Sku.find_by(sku: sku)
      #skuDB.update(reservado: skuDB["reservado"].to_i-1) //
      skuDB.increment!(:reservado, -1)

      counter = counter+1
    end
    return total+counter

  end

 def moverInventarioDespacho(sku, cantidad, almacenOrigen)
    sist = Sistema.new
    almacenDestino = JSON.parse(sist.getAlmacenes).find {|h1| h1['despacho'] == true }['_id']
    puts "Almacen de despacho " + almacenDestino
    ## Falta confirmar que exista el stock necesario
    
    ## Ejecutamos el código para mover la cantidad necesaria de 100 en 100
    total = 0
    if cantidad > 100
      total = moverInventarioDespacho(sku,cantidad-100,almacenOrigen,almacenDestino)
      cantidad = 100
    end
    
      
    ids = JSON.parse(sist.getStock(almacenOrigen , sku , cantidad))
    counter = 0
    while counter < cantidad
      begin
        result = JSON.parse(sist.moverStock(ids[counter]["_id"], almacenDestino))    
        if result["message"]
          puts "No se movio, intentando nuevamente"
          ids = JSON.parse(sist.getStock(almacenOrigen , sku , cantidad-counter))
          counter = counter-1
        end
      rescue => ex
        puts "No se movio, intentando nuevamente"
        ids = JSON.parse(sist.getStock(almacenOrigen , sku , cantidad-counter))
        counter = counter-1
      end
      puts "Movido correctamente, N= "+ counter.to_s
      skuDB = Sku.find_by(sku: sku)
      #skuDB.update(reservado: skuDB["reservado"].to_i-1)
      skuDB.increment!(:reservado, -1)
      counter = counter+1
    end
    return total+counter

  end
   def despacharFTP(sku, cantidad, direccion,precio,idOC)
    sist = Sistema.new
    almacenOrigen = JSON.parse(sist.getAlmacenes).find {|h1| h1['despacho'] == true }['_id']

    ## Falta confirmar que exista el stock necesario
    
    ## Ejecutamos el código para mover la cantidad necesaria de 100 en 100
    Rails.logger.debug("debug:: le empezamos a despachar al ftp")
    total = 0
    if cantidad > 100
      total = despachaFTP(sku,cantidad-100, direccion,precio,idOC)
      cantidad = 100
    end
    Rails.logger.debug("debug:: cantidad es menor a 100")
    stock = sist.getStock(almacenOrigen, sku , cantidad)
    Rails.logger.debug("debug::"+stock)
    ids = JSON.parse(stock)  
    Rails.logger.debug("debug::"+ids.to_s)
    counter = 0
    while counter < cantidad
      begin
        
        movStock = despacharStock(ids[counter]["_id"],direccion,precio, idOC)
        Rails.logger.debug("debug::"+movStock)
        result = JSON.parse(movStock)
            
        if result["message"]
          Rails.logger.debug("debug::"+"No se despacho, intentando nuevamente")
          ids = JSON.parse(sist.getStock(almacenOrigen , sku , cantidad-counter))
          counter = counter-1
        end
      rescue => ex
        Rails.logger.debug("debug::"+"No se despacho, intentando nuevamente")
        ids = JSON.parse(sist.getStock(almacenOrigen , sku , cantidad-counter))
        counter = counter-1
      end
      Rails.logger.debug("debug::"+"Despachado correctamente, N= "+ counter.to_s)
      counter = counter+1
    end
    return total+counter
  end
    
   def despacharCliente(sku, cantidad, direccion,precio,idOC)
    sist = Sistema.new
    almacenOrigen = JSON.parse(sist.getAlmacenes).find {|h1| h1['despacho'] == true }['_id']

    ## Falta confirmar que exista el stock necesario
    
    ## Ejecutamos el código para mover la cantidad necesaria de 100 en 100
    Rails.logger.debug("debug:: le empezamos a despachar al cliente")
    total = 0
    if cantidad > 100
      total = despacharCliente(sku,cantidad-100, direccion,precio,idOC)
      cantidad = 100
    end
    Rails.logger.debug("debug:: cantidad es menor a 100")
    stock = sist.getStock(almacenOrigen, sku , cantidad)
    Rails.logger.debug("debug::"+stock)
    ids = JSON.parse(stock)  
    Rails.logger.debug("debug::"+ids.to_s)
    counter = 0
    while counter < cantidad
      begin
        
        movStock = sist.moverStockBodega(ids[counter]["_id"],direccion,idOC,precio)
        Rails.logger.debug("debug::"+movStock)
        result = JSON.parse(movStock)
            
        if result["message"]
          Rails.logger.debug("debug::"+"No se despacho, intentando nuevamente")
          ids = JSON.parse(sist.getStock(almacenOrigen , sku , cantidad-counter))
          counter = counter-1
        end
      rescue => ex
        Rails.logger.debug("debug::"+"No se despacho, intentando nuevamente")
        ids = JSON.parse(sist.getStock(almacenOrigen , sku , cantidad-counter))
        counter = counter-1
      end
      Rails.logger.debug("debug::"+"Despachado correctamente, N= "+ counter.to_s)
      counter = counter+1
    end
    return total+counter
  end

end
