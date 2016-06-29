class HomeController < ApplicationController
  
  layout false
  
  def index


  end

  def bodegas
    @sist = Sistema.new
    @almacenesInfo = JSON.parse(@sist.getAlmacenes())
    totalspace = @almacenesInfo[0]["totalSpace"]
    totalspace = @almacenesInfo[0]["usedSpace"]
   
  
  end

  def test

        inv = Inventario.new
        inv.run
        render :text => "hola"
      #social = SocialMedium.new
      #social.searchMessages
      #social.sendMessageUrl
      #social.publishToSocialMedia("8" , 990, "25/06/2016", "23/06/2016" , "codigopromo123 " )

    #  sist = Sistema.new
     # disp = sist.getStockSKUDisponible(31)



    #[8, 6, 14, 31, 49, 55] 
      #inv = Inventario.new
     # sist = Sistema.new
     # ary = [5, 0, 0, 0,0,0] 37,116
      #despacharLista(ary, false123 , 37116 , idOc)
      #Thread.new do
        #inv.updateStockSpree()
#        sist.putStockSpree("http://localhost:8080", 2, 1)
      #end
      #render :text => sist.obtenerCartola((0).day.ago.to_time.to_i, Time.now.tomorrow.to_time.to_i, sist.idBanco)

      #diaInicial = (13).day.ago.to_date #parte desde las 4am por defecto
      #diaSiguiente = Time.now.tomorrow.to_date
     #render :text => sist.obtenerCartola(Date.new(diaInicial.year, diaInicial.month, diaInicial.day).to_time.to_i, Date.new(diaSiguiente.year, diaSiguiente.month, diaSiguiente.day).to_time.to_i, sist.idBanco)

      #diaInicial = (5).day.ago.to_date #parte desde las 4am por defecto
      #diaSiguiente = Time.now.to_date
      #puts "HORA: " + ((Date.new(diaInicial.year, diaInicial.month, diaInicial.day).to_time.to_i)*1000).to_s
      #render :text => sist.obtenerCartola(((Date.new(diaInicial.year, diaInicial.month, diaInicial.day).to_time.to_i)*1000).to_s, ((Date.new(diaSiguiente.year, diaSiguiente.month, diaSiguiente.day).to_time.to_i)*1000).to_s, sist.idBanco)
    #  facturas = Oc.where(" DATE(created_at) = ? AND factura IS NOT NULL" , (5).day.ago.to_date)      
    #  hola = nil
     # facturas.each do |row|
     #   hola = sist.obtenerFactura(row.factura)
     # end
    

  end
  
  def self.guardaSaldoDiarioYStock
      sist = Sistema.new
      #skuTrabajados = [8, 6, 14, 31, 49, 55] #están en orden según el id de spree
      Saldo.find_or_create_by(fecha:(1).day.ago.to_date, monto: JSON.parse(sist.obtenerCuenta(sist.idBanco))[0]["saldo"])
      stockTotal = checkStockTotal()
      Stockfecha.find_or_create_by(fecha:(1).day.ago.to_date, sku: 8, cantidad: stockTotal[0])
      Stockfecha.find_or_create_by(fecha:(1).day.ago.to_date, sku: 6, cantidad: stockTotal[1])
      Stockfecha.find_or_create_by(fecha:(1).day.ago.to_date, sku: 14, cantidad: stockTotal[2])
      Stockfecha.find_or_create_by(fecha:(1).day.ago.to_date, sku: 31, cantidad: stockTotal[3])
      Stockfecha.find_or_create_by(fecha:(1).day.ago.to_date, sku: 49, cantidad: stockTotal[4])
      Stockfecha.find_or_create_by(fecha:(1).day.ago.to_date, sku: 55, cantidad: stockTotal[5])
  end

  def numBoletas date

      boletas = Boletum.where(" DATE(created_at) = ?" , date)
      puts "date "  + date.to_s
      puts "boldetas "  + boletas.to_s
      return boletas.count   
  end

  def numBoletasCanal date

      boletas = Boletum.where(" DATE(created_at) = ?" , date)
      total = []
      contFTP = 0
      contB2B = 0
      contB2C = 0
      boletas.each do |row|
        id_oc = row.orden_id 
        orden = Oc.find_by(oc: id_oc)
        if orden.nil?

        elsif orden.canal == "ftp"
          contFTP = contFTP + 1
        elsif orden.canal == "b2b"
          contB2B = contB2B + 1
        elsif orden.canal == "b2c"
          contB2C = contB2C + 1
        end
      end 
      total.push(contFTP)
      total.push(contB2B)
      total.push(contB2C)
      return total  
  end

   def numFacturas date

      facturas = Oc.where(" DATE(created_at) = ? AND factura IS NOT NULL" , date)
      puts "date "  + date.to_s
      puts "boldetas "  + facturas.to_s
      return facturas.count   
  end

  def numFacturasCanal date

      total = []      
      facturasFTP = Oc.where(" DATE(created_at) = ? AND canal = ? AND factura IS NOT NULL" , date, "ftp")
      facturasB2B = Oc.where(" DATE(created_at) = ? AND canal = ? AND factura IS NOT NULL" , date, "b2b")
      facturasB2C = Oc.where(" DATE(created_at) = ? AND canal = ? AND factura IS NOT NULL" , date, "b2c")
      contFTP = facturasFTP.count
      contB2B = facturasB2B.count
      contB2C = facturasB2C.count
      total.push(contFTP)
      total.push(contB2B)
      total.push(contB2C)
      return total  
  end

  def montoBoletas date
      boletas = Boletum.where(" DATE(created_at) = ?" , date)
      total = 0
      boletas.each do |row|
        total = total + row.total 
      end 
      return total  
  end

  def montoBoletasCanal date
      boletas = Boletum.where(" DATE(created_at) = ?" , date)
      total = []
      contFTP = 0
      contB2B = 0
      contB2C = 0
      boletas.each do |row|
        id_oc = row.orden_id 
        orden = Oc.find_by(oc: id_oc)
        if orden.nil?
          #NO SUMA porque no la encuentra
        elsif orden.canal == "ftp"
          contFTP = contFTP + row.total
        elsif orden.canal == "b2b"
          contB2B = contB2B + row.total
        elsif orden.canal == "b2c"
          contB2C = contB2C + row.total
        end
      end 
      total.push(contFTP)
      total.push(contB2B)
      total.push(contB2C)
      return total  
  end

  def montoFacturas date
      total = 0    
      sist = Sistema.new
      facturas = Oc.where(" DATE(created_at) = ? AND factura IS NOT NULL" , date)      
      facturas.each do |row| 
        #puts "PRUEBA : " + JSON.parse(sist.obtenerFactura(row.factura))[0]['total'].to_s
        begin
          montoTotal = JSON.parse(sist.obtenerFactura(row.factura))[0]['total'].to_s
          total = total + montoTotal.to_i#.select{|h1|}["total"].to_i
        rescue Exception => e 
        end
      end
      return total  
  end

  def montoFacturasCanal date

      total = []   
      sist = Sistema.new   
      facturasFTP = Oc.where(" DATE(created_at) = ? AND canal = ? AND factura IS NOT NULL" , date, "ftp")
      facturasB2B = Oc.where(" DATE(created_at) = ? AND canal = ? AND factura IS NOT NULL" , date, "b2b")
      facturasB2C = Oc.where(" DATE(created_at) = ? AND canal = ? AND factura IS NOT NULL" , date, "b2c")
      contFTP = 0
      contB2B = 0
      contB2C = 0
      facturasFTP.each do |row|
        begin
        montoTotal = JSON.parse(sist.obtenerFactura(row.factura))[0]['total'].to_s
        contFTP = contFTP + montoTotal.to_i
        rescue Exception => e 
        end
      end
      facturasB2B.each do |row|
        begin
        montoTotal = JSON.parse(sist.obtenerFactura(row.factura))[0]['total'].to_s
        contB2B = contB2B + montoTotal.to_i
        rescue Exception => e 
        end
      end
      facturasB2C.each do |row|
        begin
        montoTotal = JSON.parse(sist.obtenerFactura(row.factura))[0]['total'].to_s
        contB2C = contB2C + montoTotal.to_i
        rescue Exception => e 
        end
      end
      
      total.push(contFTP)
      total.push(contB2B)
      total.push(contB2C)
      return total  
  end

  def dashboard
    
    #pavucontrol
    sist = Sistema.new
    saldoActual = JSON.parse(sist.obtenerCuenta(sist.idBanco))[0]["saldo"]
    @diasEjeX = []
    @saldosEjeY = []
    @detalleTransacciones = []
    #######
    #######
    ###Primer gráfico
    for i in 0..13
       @diasEjeX.push((13-i).day.ago.to_date)  
       if i == 13            
            @saldosEjeY.push(saldoActual)
       else
            resp = Saldo.find_by(fecha: (13-i).day.ago.to_date)
            if resp.nil?
              @saldosEjeY.push(0)
            else              
              monto = resp.monto
              @saldosEjeY.push(monto)
            end              
       end
       diaInicial = (13-i).day.ago.to_date #parte desde las 4am por defecto
       diaSiguiente = Time.now.tomorrow.to_date
       if i != 13
        diaSiguiente = (13-i-1).day.ago.to_date #parte desde las 4am por defecto
       end       
       #.to_time.to_i)*1000)
       cartolaDiaria = JSON.parse(sist.obtenerCartola((Date.new(diaInicial.year, diaInicial.month, diaInicial.day).to_time.to_i)*1000, (Date.new(diaSiguiente.year, diaSiguiente.month, diaSiguiente.day).to_time.to_i)*1000, sist.idBanco))
       puts "UNIX time: " + ((Date.new(diaInicial.year, diaInicial.month, diaInicial.day).to_time.to_i)*1000).to_s + "   " + ((Date.new(diaSiguiente.year, diaSiguiente.month, diaSiguiente.day).to_time.to_i)*1000).to_s
       if cartolaDiaria["data"].length != 0          
          transaccion = "Transacciones:" + '\n'
         for u in 0..(cartolaDiaria["data"].length-1)
          transaccion = transaccion + (u+1).to_s + ") id: " + (cartolaDiaria["data"][u]["_id"]).to_s + '\n' + "   origen: " + (cartolaDiaria["data"][u]["origen"]).to_s + '\n' + "   created_at: "+ (cartolaDiaria["data"][u]["created_at"]).to_s + '\n' + "   destino: " + (cartolaDiaria["data"][u]["destino"]).to_s + '\n' + "   monto: " + (cartolaDiaria["data"][u]["monto"]).to_s + '\n'
         end
         @detalleTransacciones.push(transaccion)
         puts "TRANSACCIÓN: " + transaccion
       else 
         @detalleTransacciones.push("No hay transacciones para este día")
       end

    end
    #######
    #######
    ###Segundo gráfico
    @diasEjeXBoletas = []
    @saldosEjeYBoletas = []
    @saldosEjeYFacturas = []
    @detalleBoletasFacturas = []
    for i in 0..13
       @diasEjeXBoletas.push((13-i).day.ago.to_date)  
   
        date = (13-i).day.ago.to_date
        numb = numBoletas(date)
        numf = numFacturas(date)
        #puts "nume  " + num.to_s       
        @saldosEjeYBoletas.push(numb)
        @saldosEjeYFacturas.push(numf)       
         
        #la cantidad de boletas van a ser todas b2c
        canalesBoleta = numb#numBoletasCanal(date)  
        canalesFactura = numFacturasCanal(date)  
        boletaFactura = "Facturas: " + '\n' + " - ftp = " + (canalesFactura[0]).to_s + '\n' + " - b2b = " + (canalesFactura[1]).to_s + '\n' + " - b2c = " + (canalesFactura[2]).to_s + '\n'
        boletaFactura = boletaFactura + "Boletas: " + '\n' + " - ftp = " + (0).to_s + '\n' + " - b2b = " + (0).to_s + '\n' + " - b2c = " + (canalesBoleta).to_s + '\n'
        @detalleBoletasFacturas.push(boletaFactura)
    end
    #######
    #######
    ###Tercer gráfico
    @diasEjeXBoletasP = []
    @saldosEjeYBoletasP = []
    @saldosEjeYFacturasP = []
    @detalleBoletasFacturasP = []
    for i in 0..13
       @diasEjeXBoletasP.push((13-i).day.ago.to_date)  
   
        date = (13-i).day.ago.to_date
        montob = montoBoletas(date)
        montof = montoFacturas(date)
        #puts "nume  " + num.to_s       
        @saldosEjeYBoletasP.push(montob)
        @saldosEjeYFacturasP.push(montof)       
         
        #la cantidad de boletas van a ser todas b2c
        canalesBoleta = montob#montoBoletasCanal(date)  
        canalesFactura = montoFacturasCanal(date)  
        boletaFactura = "Facturas: " + '\n' + " - ftp = " + (canalesFactura[0]).to_s + '\n' + " - b2b = " + (canalesFactura[1]).to_s + '\n' + " - b2c = " + (canalesFactura[2]).to_s + '\n'
        boletaFactura = boletaFactura + "Boletas: " + '\n' + " - ftp = " + (0).to_s + '\n' + " - b2b = " + (0).to_s + '\n' + " - b2c = " + (canalesBoleta).to_s + '\n'
        @detalleBoletasFacturasP.push(boletaFactura)
    end
    #######
    #######
    ###Cuarto gráfico
    @diasEjeXStock = []
    @stockEjeYTrigo = []
    @stockEjeYCrema = []
    @stockEjeYCebada = []
    @stockEjeYLana = []
    @stockEjeYLecheD = []
    @stockEjeYGalletaI = []
    for i in 0..13

       @diasEjeXStock.push((13-i).day.ago.to_date)     
        date = (13-i).day.ago.to_date
        #skuTrabajados = [8, 6, 14, 31, 49, 55] #están en orden según el id de spree
        if i != 13
          resp = Stockfecha.where("DATE(fecha) = ?" , date)
          if resp.empty?
            @stockEjeYTrigo.push(0) 
            @stockEjeYCrema.push(0) 
            @stockEjeYCebada.push(0) 
            @stockEjeYLana.push(0) 
            @stockEjeYLecheD.push(0) 
            @stockEjeYGalletaI.push(0)   
          else
            #puts resp.to_s
            #if resp.length == 6
              resp.each do |row|
                if row.sku == 8          
                  @stockEjeYTrigo.push(row.cantidad)   
                elsif row.sku == 6          
                  @stockEjeYCrema.push(row.cantidad)  
                elsif row.sku == 14         
                  @stockEjeYCebada.push(row.cantidad)   
                elsif row.sku == 31         
                  @stockEjeYLana.push(row.cantidad)   
                elsif row.sku == 49          
                  @stockEjeYLecheD.push(row.cantidad)   
                elsif row.sku == 55          
                  @stockEjeYGalletaI.push(row.cantidad)  
                end
              end 
            #else
            #  @stockEjeYTrigo.push(0) 
            #  @stockEjeYCrema.push(0) 
            #  @stockEjeYCebada.push(0) 
            #  @stockEjeYLana.push(0) 
            #  @stockEjeYLecheD.push(0) 
            #  @stockEjeYGalletaI.push(0) 
            #end
          end
        else
          #puts "stock Crema: " + sist.getStockSKUDisponible(6).to_s
          stockTotal = checkStockTotal()
          @stockEjeYTrigo.push(stockTotal[0]) 
          @stockEjeYCrema.push(stockTotal[1]) 
          @stockEjeYCebada.push(stockTotal[2]) 
          @stockEjeYLana.push(stockTotal[3]) 
          @stockEjeYLecheD.push(stockTotal[4]) 
          @stockEjeYGalletaI.push(stockTotal[5])   
        end        
    end
    #######
    #######
    ###Quinto-Décimo gráfico
    @stockEjeXBodega = []
    @stockEjeYBodega = []
    @stockEjeXRecepcion = []
    @stockEjeYRecepcion = []
    @stockEjeXDespacho = []
    @stockEjeYDespacho = []
    @stockEjeXPulmon = []
    @stockEjeYPulmon = []
    @stockEjeXGrande = []
    @stockEjeYGrande = []
    @stockEjeXChica = []
    @stockEjeYChica = []

    @stockEjeXBodega.push("Ocupado")    
    @stockEjeXBodega.push("Espacio Disponible")  
    @stockEjeXRecepcion.push("Ocupado")    
    @stockEjeXRecepcion.push("Espacio Disponible")  
    @stockEjeXDespacho.push("Ocupado")    
    @stockEjeXDespacho.push("Espacio Disponible")  
    @stockEjeXPulmon.push("Ocupado")    
    @stockEjeXPulmon.push("Espacio Disponible")  
    @stockEjeXGrande.push("Ocupado")    
    @stockEjeXGrande.push("Espacio Disponible")  
    @stockEjeXChica.push("Ocupado")    
    @stockEjeXChica.push("Espacio Disponible")  

    intermedios = JSON.parse(sist.getAlmacenes()).select {|h1| h1['despacho'] == false && h1['pulmon'] == false && h1['recepcion'] == false }
    ## Revisamos la bodega grande
    almacenGrandeTotal = intermedios.max_by { |quote| quote["totalSpace"].to_f }["totalSpace"]
    almacenGrandeUso = intermedios.max_by { |quote| quote["totalSpace"].to_f }["usedSpace"]
    ## Revisamos la bodega chica
    almacenChicoTotal = intermedios.min_by { |quote| quote["totalSpace"].to_f }["totalSpace"]
    almacenChicoUso = intermedios.min_by { |quote| quote["totalSpace"].to_f }["usedSpace"]

    recepcion = JSON.parse(sist.getAlmacenes()).select {|h1| h1['despacho'] == false && h1['pulmon'] == false && h1['recepcion'] == true }
    ## Revisamos la bodega recepcion
    recepcionTotal = recepcion.max_by { |quote| quote["totalSpace"].to_f }["totalSpace"]
    recepcionUso = recepcion.max_by { |quote| quote["totalSpace"].to_f }["usedSpace"]

    despacho = JSON.parse(sist.getAlmacenes()).select {|h1| h1['despacho'] == true && h1['pulmon'] == false && h1['recepcion'] == false }
    ## Revisamos la bodega despacho
    despachoTotal = despacho.max_by { |quote| quote["totalSpace"].to_f }["totalSpace"]
    despachoUso = despacho.max_by { |quote| quote["totalSpace"].to_f }["usedSpace"]

    pulmon = JSON.parse(sist.getAlmacenes()).select {|h1| h1['despacho'] == false && h1['pulmon'] == true && h1['recepcion'] == false }
    ## Revisamos la bodega pulmon
    pulmonTotal = pulmon.max_by { |quote| quote["totalSpace"].to_f }["totalSpace"]
    pulmonUso = pulmon.max_by { |quote| quote["totalSpace"].to_f }["usedSpace"]

    #no se considera la pulmón para sacar el total
    totalAlmacenes = (almacenGrandeTotal + almacenChicoTotal + recepcionTotal + despachoTotal).to_f
    totalUsado = (almacenGrandeUso + almacenChicoUso + recepcionUso + despachoUso).to_f
    redondearA = 100.0
    totalPorcentajeUso = (((totalUsado/totalAlmacenes)*100*redondearA).floor/redondearA).to_s
    totalPorcentajeDisponible = (((1-totalUsado/totalAlmacenes)*100*redondearA).floor/redondearA).to_s

    @stockEjeYBodega.push(totalPorcentajeUso)    
    @stockEjeYBodega.push(totalPorcentajeDisponible)    
    @stockEjeYGrande.push((((almacenGrandeUso.to_f/almacenGrandeTotal.to_f)*100*redondearA).floor/redondearA).to_s)
    @stockEjeYGrande.push((((1-almacenGrandeUso.to_f/almacenGrandeTotal.to_f)*100*redondearA).floor/redondearA).to_s)
    @stockEjeYChica.push((((almacenChicoUso.to_f/almacenChicoTotal.to_f)*100*redondearA).floor/redondearA).to_s)
    @stockEjeYChica.push((((1-almacenChicoUso.to_f/almacenChicoTotal.to_f)*100*redondearA).floor/redondearA).to_s)
    @stockEjeYRecepcion.push((((recepcionUso.to_f/recepcionTotal.to_f)*100*redondearA).floor/redondearA).to_s)
    @stockEjeYRecepcion.push((((1-recepcionUso.to_f/recepcionTotal.to_f)*100*redondearA).floor/redondearA).to_s)
    @stockEjeYDespacho.push((((despachoUso.to_f/despachoTotal.to_f)*100*redondearA).floor/redondearA).to_s)
    @stockEjeYDespacho.push((((1-despachoUso.to_f/despachoTotal.to_f)*100*redondearA).floor/redondearA).to_s)
    @stockEjeYPulmon.push((((pulmonUso.to_f/pulmonTotal.to_f)*100*redondearA).floor/redondearA).to_s)
    @stockEjeYPulmon.push((((1-pulmonUso.to_f/pulmonTotal.to_f)*100*redondearA).floor/redondearA).to_s)        
  end
  
  #devuelve un arreglo con el stock total de los 6 sku en orden
  def self.checkStockTotal
    require 'json'
    sist = Sistema.new
    almac = sist.getAlmacenes
    intermedio = JSON.parse(almac).select {|h1| h1['despacho'] == false && h1['pulmon'] == false && h1['recepcion'] == false }
    bodegaPrincipal = intermedio.max_by { |quote| quote["totalSpace"].to_f }["_id"]
    bodegaChica = intermedio.min_by { |quote| quote["totalSpace"].to_f }["_id"]
    bodegaRecepcion = JSON.parse(almac).find {|h1| h1['recepcion'] == true }['_id']
    #bodegaPulmon = JSON.parse(almac).find {|h1| h1['pulmon'] == true }['_id']
    bodegaDespacho = JSON.parse(almac).find {|h1| h1['despacho'] == true }['_id']
    principal = JSON.parse(sist.getSKUWithStock(bodegaPrincipal))
    chica = JSON.parse(sist.getSKUWithStock(bodegaChica))
    recepcion = JSON.parse(sist.getSKUWithStock(bodegaRecepcion))
    despacho = JSON.parse(sist.getSKUWithStock(bodegaDespacho))
    #pulmon = JSON.parse(sist.getSKUWithStock(@bodegaPulmon))

    stock = [] #en orden 8, 6, 14, 31, 49, 55
    trigo = 0
    crema = 0
    cebada = 0
    lana = 0
    lecheD = 0
    galletasI = 0
    for counter in 0..(principal.length-1)
      sku = principal[counter]['_id'].to_i
      if(sku == 8)
        trigo = trigo + principal[counter]['total'].to_i
      elsif(sku == 6)
        crema = crema + principal[counter]['total'].to_i
      elsif(sku == 14)
        cebada = cebada + principal[counter]['total'].to_i
      elsif(sku == 31)
        lana = lana + principal[counter]['total'].to_i
      elsif(sku == 49)
        lecheD = lecheD + principal[counter]['total'].to_i
      elsif(sku == 55)
        galletasI = galletasI + principal[counter]['total'].to_i
      end
    end
    for counter in 0..(chica.length-1)
      sku = chica[counter]['_id'].to_i
      if(sku == 8)
        trigo = trigo + chica[counter]['total'].to_i
      elsif(sku == 6)
        crema = crema + chica[counter]['total'].to_i
      elsif(sku == 14)
        cebada = cebada + chica[counter]['total'].to_i
      elsif(sku == 31)
        lana = lana + chica[counter]['total'].to_i
      elsif(sku == 49)
        lecheD = lecheD + chica[counter]['total'].to_i
      elsif(sku == 55)
        galletasI = galletasI + chica[counter]['total'].to_i
      end
    end
    for counter in 0..(recepcion.length-1)
      sku = recepcion[counter]['_id'].to_i
      if(sku == 8)
        trigo = trigo + recepcion[counter]['total'].to_i
      elsif(sku == 6)
        crema = crema + recepcion[counter]['total'].to_i
      elsif(sku == 14)
        cebada = cebada + recepcion[counter]['total'].to_i
      elsif(sku == 31)
        lana = lana + recepcion[counter]['total'].to_i
      elsif(sku == 49)
        lecheD = lecheD + recepcion[counter]['total'].to_i
      elsif(sku == 55)
        galletasI = galletasI + recepcion[counter]['total'].to_i
      end
    end
    for counter in 0..(despacho.length-1)
      sku = despacho[counter]['_id'].to_i
      if(sku == 8)
        trigo = trigo + despacho[counter]['total'].to_i
      elsif(sku == 6)
        crema = crema + despacho[counter]['total'].to_i
      elsif(sku == 14)
        cebada = cebada + despacho[counter]['total'].to_i
      elsif(sku == 31)
        lana = lana + despacho[counter]['total'].to_i
      elsif(sku == 49)
        lecheD = lecheD + despacho[counter]['total'].to_i
      elsif(sku == 55)
        galletasI = galletasI + despacho[counter]['total'].to_i
      end
    end
    stock.push(trigo)
    stock.push(crema)
    stock.push(cebada)
    stock.push(lana)
    stock.push(lecheD)
    stock.push(galletasI)
    return stock      
  end


  def recibirStock
    
        inv = Inventario.new
        inv.definirVariables
        inv.moverInventario(params[:sku].to_i,params[:cantidad].to_i,params[:desde],params[:hasta])
  
    render :text => "hola"
  end

  def insertPromotion
    sm = SocialMedium.new
    sm.insertPromotionSpree(55,1500,"2016-01-01 00:00:00","2016-08-08 00:00:00","webeta")
  end
  def updatePromotions
    sm = SocialMedium.new
    sm.searchMessages
  end
end
