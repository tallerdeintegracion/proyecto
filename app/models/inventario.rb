class Inventario < ActiveRecord::Base

  def run

    definirVariables 
    puts "\n \n \n \n "
    puts "#{Time.now}  Inicia revicion de inventario "
    cleanProduccionesDespachadas()
    vaciarAlmacenesRecepcion(@bodegaRecepcion, @bodegaPulmon , @bodegaPrincipal)
    checkMateriasPrimas(@bodegaPrincipal)
    checkCompraMaterial(@bodegaPrincipal)
    producirMaterialesProcesados(@bodegaPrincipal)

  end

  def definirVariables 
    @sist = Sistema.new
    @returnPoint = 2000
    @returnPointProcesados = 400
   
    @bodegaPrincipal = "571262aaa980ba030058a1f3"
    @bodegaRecepcion = "571262aaa980ba030058a1f1"
    @bodegaPulmon = "571262aaa980ba030058a23e"
    @bodegaDespacho = "571262aaa980ba030058a1f2"
    @cuentaGrupo = "571262c3a980ba030058ab5d"
    @GrupoProyecto="3";
    @cuentaFabrica = JSON.parse(@sist.getCuentaFabrica)["cuentaId"]
    @horasEntrega = 4

  end 

  def cleanProduccionesDespachadas()
    puts "\n"
    puts "1) #{Time.now}  Limpiando producciones despachadas del registro"
    puts "\n"
    time = Time.now
    produccion = Production.where( 'disponible <= ?', time )
    puts "--- Fueron removidas  " + produccion.count.to_s + " entregas de la tabla de produccion "
    produccion.destroy_all  
    ocs = SentOrder.where( 'fechaEntrega <= NOW()')
    puts "--- Fueron removidas  " + ocs.count.to_s + " entregas de la tabla de ocs enviadas "
    ocs.destroy_all
  end

  def vaciarAlmacenesRecepcion(bodegaRecepcion , bodegaPulmon, bodegaPrincipal)
    puts "\n"
    puts "2) #{Time.now} Recibiendo material de almacen de recepcion "
    puts "\n"
    materias = Sku.where("grupoProyecto = ? AND tipo = ?"  , @GrupoProyecto , "Materia Prima")
    
    materias.each do |row|
      sku = row.sku 
      inicialRececpcion = recibirMaterial(sku, bodegaRecepcion, bodegaPrincipal)
      inicialPulmon = recibirMaterial(sku, bodegaPulmon, bodegaPrincipal)
      puts "--- Recibiendo sku " + sku + " Recepcion: " + inicialRececpcion.to_s + " Pulmon: " + inicialPulmon.to_s 
    end

    materias = Sku.where("grupoProyecto = ? AND tipo = ?"  , @GrupoProyecto , "Producto procesado")
    materias.each do |row|
      sku = row.sku 
      inicialRececpcion = recibirMaterial(sku, bodegaRecepcion, bodegaPrincipal)
      inicialPulmon = recibirMaterial(sku, bodegaPulmon, bodegaPrincipal)
      puts "--- Recibiendo sku " + sku + " Recepcion: " + inicialRececpcion.to_s + " Pulmon: " + inicialPulmon.to_s 
      ingrediente = Formula.where("sku = ?"  , sku)
    
      ingrediente.each do |ing|
        skuMaterial = ing.skuIngerdiente  
        inicialRececpcion = recibirMaterial(skuMaterial, bodegaRecepcion, bodegaPrincipal)
        inicialPulmon =recibirMaterial(skuMaterial, bodegaPulmon, bodegaPrincipal)
        puts "--- Recibiendo sku " + skuMaterial + " Recepcion: " + inicialRececpcion.to_s + " Pulmon: " + inicialPulmon.to_s 
      end 
    end

  end

  def recibirMaterial( sku , almacenRecepcion , bodegaMateriasPrimas)
            
      stock = checkStock(sku ,almacenRecepcion) 
      stockInicial = stock  
      moverInventario(sku, stock, almacenRecepcion, bodegaMateriasPrimas)
      return stockInicial
  end

def moverInventario(sku, cantidad, almacenOrigen,almacenDestino)
    sist = Sistema.new
    #puts "Almacen de destino " + almacenDestino
    ## Falta confirmar que exista el stock necesario
    ## Ejecutamos el código para mover la cantidad necesaria de 100 en 100
    total = 0
    if cantidad > 100
      total = moverInventario(sku,cantidad-100,almacenOrigen,almacenDestino)
      cantidad = 100
    end
    ids = JSON.parse(@sist.getStock(almacenOrigen , sku , cantidad))
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

  def checkMateriasPrimas(bodega)
    puts "\n"
    puts " 3) #{Time.now}  Revisando si es necesario producir materias primas"  
    puts "\n"
    materias = Sku.where("grupoProyecto = ? AND tipo = ?"  , @GrupoProyecto , "Materia Prima")
    materias.each do |row|
      sku = row.sku
      coste = row.costoUnitario
      tamanoLote = row.loteProduccion
      puts "--- Material " + sku.to_s + " coste: " + coste.to_s + " tamano lote: "+tamanoLote.to_s
      stock = checkStock(sku, bodega)
      puts "--- Stock del sku es de: " + stock.to_s 
  
      produccion = enProduccion(sku)
      puts "--- Existen en produccion: " + produccion.to_s

      lotes = calcularLotes(stock, produccion , tamanoLote, @returnPoint)
      puts "--- Lotes a producir: " + lotes.to_s
  
      monto = lotes*coste*tamanoLote  
    
      if lotes <= 0
        puts "--- No es necesario producir" 
      else

        trx =pagar(monto , @cuentaGrupo , @cuentaFabrica  );
        puts "--- Transferencia exitosa " + trx
        cantidad= lotes*tamanoLote
        detallesProd = producir(sku, trx, cantidad)
        puts "--- Se enviaro a producir " + cantidad.to_s + " de la transaccion " +trx  
        actualizarRegistoProduccion(detallesProd , sku , cantidad)
        puts "--- Registro produccion actualizado "  
      end
    end  

  end 

  def calcularLotes(stock , enproduccion , tamanoLote ,returnPoint )

    total= stock + enproduccion
    faltante = returnPoint - total
    lotes = (faltante/tamanoLote).to_i
    if lotes < 0
      return 0
    end 
    return lotes

  end 

  def checkStock(sku , bodega)
    require 'json'
    result = JSON.parse(@sist.getSKUWithStock(bodega))

    if result.nil?
      return 0
    end 
    stock =0
    for counter in 0..(result.length-1)

      actualSku =result[counter]['_id'].to_s

      if(sku == actualSku)
        actualTotal =result[counter]['total'].to_i
        stock = actualTotal 
      end
    end

  if stock.nil? 
    return 9000000 
  end
  
  return stock
      
  end



  def generarOrdenesDeCompra(sku , cantidad , precioUnitario, grupo )
    require 'json'
    require 'rubygems'
    ## get id grupo
    canal ="b2b"
    nota = "LoQuieroAhora" ## no deven haver espacioss
    resp = Grupo.find_by(nGrupo: grupo.to_i) 
    proveedor = resp.idGrupo  
    resp = Grupo.find_by(nGrupo: @GrupoProyecto) 
    cliente = resp.idGrupo  
    puts "--- Generando  proveedor: " + proveedor + " cliente: " + cliente + " cantidad: " + cantidad.to_s
    fechaHoy = Time.now.to_i*1000
    fechaEntrega= fechaHoy + 4*3600*1000
    if cliente.empty? or proveedor.empty?
      return nil
    end 
    
    String orden = eval(@sist.crearOrdenDeCompra(canal , cantidad , sku , cliente , proveedor , precioUnitario ,   fechaEntrega , nota ))
  
    json = orden.to_json
    unHash = JSON.parse(json)
    retorno = unHash["_id"]
    return retorno
  
  end 

  def producirMaterialesProcesados(bodega)
    puts "\n"
    puts "5) #{Time.now}  Revisando si es necesario producir productos procesados "
    puts "\n" 
    materias = Sku.where("grupoProyecto = ? AND tipo = ?"  , @GrupoProyecto , "Producto procesado")
      materias.each do |row|
      
        revisarMaterialProcesado(row , bodega)
      end       
  end 

  def revisarMaterialProcesado(row , bodega)

      sku = row.sku
      coste = row.costoUnitario
      tamanoLote = row.loteProduccion
      puts "--- Revisando material " + sku.to_s + " coste " + coste.to_s + " tamano lote "+tamanoLote.to_s
      stock = checkStock(sku, bodega)
      puts "--- Stock del sku " + sku.to_s + " es de " + stock.to_s 
      produccion = enProduccion(sku)
      puts "--- Existen en produccion " + produccion.to_s
      lotes = calcularLotes(stock, produccion , tamanoLote, @returnPoint)
      puts "--- Lotes faltantes " + lotes.to_s
      maxLotes =  numeroLotesPosible(sku , bodega )
      puts "--- Maximo de lotes a producir con materias disponibles: "+ maxLotes.to_s

      produccion = 0
      if maxLotes > lotes
        produccion = lotes
      else
        produccion = maxLotes
      end   
      if produccion == 0
        return 
      end
      
      cantidad = produccion *tamanoLote
      puts "--- Se mandaran a producir " + cantidad.to_s  + " lotes"
      
      exito =  llevarMateriaPrimasADespacho(sku , produccion)
      
      if exito == false
        puts "--- Hubo un fallo en el movimiento de materias primas a despacho "
        return 
      end 
        
      monto = produccion * tamanoLote * coste

      trx = pagar(monto , @cuentaGrupo , @cuentaFabrica  );
        puts "--- Transferencia exitosa " + trx

        detallesProd = producir(sku, trx, cantidad)
        puts "--- Se enviaro a producir " + cantidad.to_s + " de la transaccion " +trx 
        
        actualizarRegistoProduccion(detallesProd , sku , cantidad)
        puts "--- Registro produccion actualizado "  
      

  end 

  def enProduccion(sku)
      
    produccion = Production.where(sku: sku)
    if produccion.nil?
      return 0
    else
      return produccion.sum("cantidad")
    end

  end

  def numeroLotesPosible(sku , bodega )
      materias = Formula.where("sku = ?"  , sku)
      maxLotes = 100
      materias.each do |ing|

      skuMaterial = ing.skuIngerdiente
      nececidad = ing.requerimiento 
      stockMaterial = checkStock(skuMaterial , bodega)
      lotes = (stockMaterial/nececidad).to_i
     
      if maxLotes > lotes
        maxLotes=lotes
      end 

    end 
    return maxLotes
  end 

  def llevarMateriaPrimasADespacho(sku , lotes )
      
      materias = Formula.where("sku = ?"  , sku)
      correcto ==true
      materias.each do |ing|  
      skuIngrediente = ing.skuIngerdiente
      cantidadPorLote = ing.requerimiento
      cantidadTotal = cantidadPorLote*lotes
      origen = @bodegaPrincipal
      destino = @bodegaDespacho

      movidos = moverInventario(skuIngerdiente , cantidadTotal , @bodegaPrincipal , @bodegaDespacho)
      if movidos != cantidadTotal
        correcto =false
      end 
  
    end
    return correcto

  end

  def checkCompraMaterial(bodega)
    puts "\n"
    puts "4) #{Time.now}  Revisando si son necesarios comprar material para productos procesados  "
    puts "\n"
    prod = Sku.where("grupoProyecto = ? AND tipo = ?"  , @GrupoProyecto , "Producto procesado")
    
    prod.each do |row|

      sku = row.sku
      puts "--- Revisando materiales para producir  "+ sku
      materias = Formula.where("sku = ?"  , sku)
      materias.each do |ing|
      revisarIngrediente(ing , bodega)      

      end 
    end
  
  end

  def revisarIngrediente (ing , bodega)

    skuMaterial = ing.skuIngerdiente
    puts "--- Revisando ingrediente   " + skuMaterial
    stock = checkStock(skuMaterial, bodega)
    puts "--- Stock del sku " + skuMaterial + " es de " + stock.to_s 
    resp = Sku.find_by(sku:skuMaterial)
    
    grupo =  resp.grupoProyecto 

    if(grupo == @GrupoProyecto)
      puts "--- El ingrediente es producido por el grupo, se esperara la produccion"
      return
    end  


    cantidadOrden = tamanoOrden(stock , skuMaterial , grupo)
    
    if cantidadOrden <= 0
      return
    end 

    resp = Precio.find_by(sku:skuMaterial)
    precioOrden = resp.precioUnitario
    id = generarOrdenesDeCompra(skuMaterial , cantidadOrden , precioOrden , grupo)
    
    if id.nil?
      puts "--- No fue posible  ingresar orden de compra "
      return
    end 
    
    aceptado = sendOc(grupo , id)

 
    if aceptado == false
      data = @sist.anularOrdenDeCompra(id , "Fue rechazada")
      puts "--- La orden fue rechazada y anulada del sistema " 
      return
    end 
    
    puts "--- La orden de compra fue aceptada "
    actualizarRegistoOc(id )
         
  end   
  
  def actualizarRegistoOc(id )

    resp = JSON.parse(obtenerOrdenDeCompra(id)).first
    #puts resp
    sku = resp['sku']
    estado = resp["estado"]
    cantidad= resp["cantidad"]
    fechaEntrega = resp["fechaEntrega"]

    puts "--- Registrando oc sku: " + sku + " estado: " + estado + " cantidad " + estado + " entrega: " + fechaEntrega
    res = SentOrder.find_or_create_by(oc:id , sku: sku , estado: estado, cantidad: cantidad , fechaEntrega: fechaEntrega)
    puts "--- Resultado oc: " + res.to_s
    puts "--- Se registro el envio de la oc " + id

  end 

  def tamanoOrden(stock , skuMaterial , grupo)
    pedidas = pedidas(skuMaterial)
  faltante = @returnPoint -(stock + pedidas)
    
    puts "--- Ya se han pedido " + pedidas.to_s

    if faltante <= 0
      puts "--- No es necesario comprar stock" 
      return 0  
    else

    stockGrupo = getStockOfGroup(skuMaterial , grupo)
    puts  "--- El stock reportado por el grupo es de " + stockGrupo.to_s 
    orden = 0

      if stockGrupo <= 0 
        puts "--- El grupo no tiene stock  "
        return 0
      elsif faltante > stockGrupo     
        puts "--- Generando orden de compra por la totalidad del stock " +  stockGrupo.to_s 
        return stockGrupo

      else
        puts "--- Generando orden de compra por el faltante " + faltante.to_s
        return faltante
      end 
      #puts "--- pidiendo al grupo " + grupo.to_s + "  " + faltante.to_s + " unidades"
    end 

  end   


  def getStockOfGroup(sku , group)
    url = "http://integra"+group+".ing.puc.cl/api/consultar/" +sku
    puts "--- Consultando el stock de " + url

    resp = @sist.httpGetRequest( url, nil)

    if resp.nil?
      return -1
    end 
    if @sist.valid_json?(resp) ==false
      return -1
    end

    json =JSON.parse(resp)
    stock = json["stock"]
    return  stock

  end


  def sendOc(group , oc)
    url = "http://integra"+ group.to_s + ".ing.puc.cl/api/oc/recibir/" +oc
    puts "--- Enviando orden de compra a: " + url  
    resp = @sist.httpGetRequest( url, nil)
  
    if @sist.valid_json?(resp) ==false
      return false
    end

    json =JSON.parse(resp)
    puts "--- Respuesta " + resp
    aceptado = json["aceptado"]
    
    if aceptado.nil?
      return false
    end 
    return  aceptado 
  end

  def pedidas(sku)
      sent = SentOrder.where(sku: sku)
      if sent.nil?
        return 0
      else
        return sent.sum("cantidad")
      end
  end 



  def actualizarRegistoProduccion(detallesProd , sku , cantidad)
 
    jsonDetalles = JSON.parse(detallesProd)
    disponible= jsonDetalles["disponible"]
    puts "--- Produciendo material , disponible en " + disponible.to_s  
    Production.find_or_create_by(sku: sku , cantidad: cantidad , disponible: disponible)
  end

  

  def pagar(monto , origen , destino)

    trx = JSON.parse(@sist.transferir(monto , origen, destino))['_id']
    if trx.nil?
      p "--- Hubo un error en la transferencia" 
      return  
    end
    return trx

  end 

  def producir(sku , trx , cantidad )

  prod = @sist.producirStock(sku , trx , cantidad)
  return prod
  end     

  def verSiEnviar(idFactura)
    
    Rails.logger.debug("debug:: seguimos en el despacho")
    idOC = Oc.find_by(factura: idFactura)["oc"]
    Rails.logger.debug("debug:: seguimos en el despacho")
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

  def updateStockSpree()
  #hacer un for de los productos manejados
  #revisando llame al getSKUWithStock()
  #actualice la api con esto

    sist = Sistema.new
    require 'json'
    #PONER LUEGO LA URL CORRECTO AL ESTAR DEPLOYADO, ES DECIR, http://integra3.ing.puc.cl
    urlServidor = "http://localhost:3000"    

    stockSpree = JSON.parse(sist.getStockSpree(urlServidor))
    if stockSpree.nil?
      return false
    end   
    
    #En verdad no sirve de nada tener el stock de spree, solo queremos actualizarlo según getStockSKUDisponible
    skuTrabajados = [8, 6, 14, 31, 49, 55] #están en orden según el id de spree
    for i in 0..(skuTrabajados.length-1)
      stockDispoSku = sist.getStockSKUDisponible(skuTrabajados[i])
      sist.putStockSpree(urlServidor, stockDispoSku, (i+1))
    end 

  end 

end
