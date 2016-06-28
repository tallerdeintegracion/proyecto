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
    #[8, 6, 14, 31, 49, 55] 
      inv = Inventario.new
      sist = Sistema.new
     # ary = [5, 0, 0, 0,0,0] 37,116
      #despacharLista(ary, false123 , 37116 , idOc)
      Thread.new do
        inv.updateStockSpree()
#        sist.putStockSpree("http://localhost:8080", 2, 1)
      end
      #render :text => sist.obtenerCartola((0).day.ago.to_time.to_i, Time.now.tomorrow.to_time.to_i, sist.idBanco)
      diaInicial = (13).day.ago.to_date #parte desde las 4am por defecto
      diaSiguiente = Time.now.tomorrow.to_date
      render :text => sist.obtenerCartola(Date.new(diaInicial.year, diaInicial.month, diaInicial.day).to_time.to_i, Date.new(diaSiguiente.year, diaSiguiente.month, diaSiguiente.day).to_time.to_i, sist.idBanco)

  end
  
  def self.guardaSaldoDiarioYStock
      sist = Sistema.new
      #skuTrabajados = [8, 6, 14, 31, 49, 55] #están en orden según el id de spree
      Saldo.find_or_create_by(fecha:(1).day.ago.to_date, monto: JSON.parse(sist.obtenerCuenta(sist.idBanco))[0]["saldo"])
      Stockfecha.find_or_create_by(fecha:(1).day.ago.to_date, sku: 8, cantidad: sist.getStockSKUDisponible(8))
      Stockfecha.find_or_create_by(fecha:(1).day.ago.to_date, sku: 6, cantidad: sist.getStockSKUDisponible(6))
      Stockfecha.find_or_create_by(fecha:(1).day.ago.to_date, sku: 14, cantidad: sist.getStockSKUDisponible(14))
      Stockfecha.find_or_create_by(fecha:(1).day.ago.to_date, sku: 31, cantidad: sist.getStockSKUDisponible(31))
      Stockfecha.find_or_create_by(fecha:(1).day.ago.to_date, sku: 49, cantidad: sist.getStockSKUDisponible(49))
      Stockfecha.find_or_create_by(fecha:(1).day.ago.to_date, sku: 55, cantidad: sist.getStockSKUDisponible(55))
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
      facturas = Oc.where(" DATE(created_at) = ? AND factura IS NOT NULL" , date)      
      facturas.each do |row|
        total = total + row.pago.to_i
      end
      return total  
  end

  def montoFacturasCanal date

      total = []      
      facturasFTP = Oc.where(" DATE(created_at) = ? AND canal = ? AND factura IS NOT NULL" , date, "ftp")
      facturasB2B = Oc.where(" DATE(created_at) = ? AND canal = ? AND factura IS NOT NULL" , date, "b2b")
      facturasB2C = Oc.where(" DATE(created_at) = ? AND canal = ? AND factura IS NOT NULL" , date, "b2c")
      contFTP = 0
      contB2B = 0
      contB2C = 0
      facturasFTP.each do |row|
        contFTP = contFTP + row.pago.to_i
      end
      facturasB2B.each do |row|
        contB2B = contB2B + row.pago.to_i
      end
      facturasB2C.each do |row|
        contB2C = contB2C + row.pago.to_i
      end
      
      total.push(contFTP)
      total.push(contB2B)
      total.push(contB2C)
      return total  
  end

  def dashboard
    

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
       cartolaDiaria = JSON.parse(sist.obtenerCartola(Date.new(diaInicial.year, diaInicial.month, diaInicial.day).to_time.to_i, Date.new(diaSiguiente.year, diaSiguiente.month, diaSiguiente.day).to_time.to_i, sist.idBanco))
       if cartolaDiaria["data"].nil?
         @detalleTransacciones.push("No hay transacciones para este día")
       elsif cartolaDiaria["data"].length != 0          
          transaccion = ""
         for u in 0..(cartolaDiaria["data"].length-1)
          transaccion = transaccion + (cartolaDiaria["data"][u]) + "\n"
         end
         @detalleTransacciones.push(transaccion)
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
         
        canalesBoleta = numBoletasCanal(date)  
        canalesFactura = numFacturasCanal(date)  
        boletaFactura = "Facturas: " + '\n' + " - ftp  = " + (canalesFactura[0]).to_s + '\n' + " - b2b = " + (canalesFactura[1]).to_s + '\n' + " - b2c  = " + (canalesFactura[2]).to_s + '\n'
        boletaFactura = boletaFactura + "Boletas: " + '\n' + " - ftp  = " + (canalesBoleta[0]).to_s + '\n' + " - b2b = " + (canalesBoleta[1]).to_s + '\n' + " - b2c  = " + (canalesBoleta[2]).to_s + '\n'
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
         
        canalesBoleta = montoBoletasCanal(date)  
        canalesFactura = montoFacturasCanal(date)  
        boletaFactura = "Facturas: " + '\n' + " - ftp  = " + (canalesFactura[0]).to_s + '\n' + " - b2b = " + (canalesFactura[1]).to_s + '\n' + " - b2c  = " + (canalesFactura[2]).to_s + '\n'
        boletaFactura = boletaFactura + "Boletas: " + '\n' + " - ftp  = " + (canalesBoleta[0]).to_s + '\n' + " - b2b = " + (canalesBoleta[1]).to_s + '\n' + " - b2c  = " + (canalesBoleta[2]).to_s + '\n'
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
          if resp.nil?
            @stockEjeYTrigo.push(0) 
            @stockEjeYCrema.push(0) 
            @stockEjeYCebada.push(0) 
            @stockEjeYLana.push(0) 
            @stockEjeYLecheD.push(0) 
            @stockEjeYGalletaI.push(0)   
          else
            if resp.length == 6
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
            else
              @stockEjeYTrigo.push(0) 
              @stockEjeYCrema.push(0) 
              @stockEjeYCebada.push(0) 
              @stockEjeYLana.push(0) 
              @stockEjeYLecheD.push(0) 
              @stockEjeYGalletaI.push(0) 
            end
          end
        else
          @stockEjeYTrigo.push(sist.getStockSKUDisponible(8)) 
          @stockEjeYCrema.push(sist.getStockSKUDisponible(6)) 
          @stockEjeYCebada.push(sist.getStockSKUDisponible(14)) 
          @stockEjeYLana.push(sist.getStockSKUDisponible(31)) 
          @stockEjeYLecheD.push(sist.getStockSKUDisponible(49)) 
          @stockEjeYGalletaI.push(sist.getStockSKUDisponible(55))   
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
    totalPorcentajeUso = (totalUsado/totalAlmacenes).to_s
    totalPorcentajeDisponible = (1-totalUsado/totalAlmacenes).to_s

    @stockEjeYBodega.push(totalPorcentajeUso)    
    @stockEjeYBodega.push(totalPorcentajeDisponible)    
    @stockEjeYGrande.push((almacenGrandeUso.to_f/almacenGrandeTotal.to_f).to_s)
    @stockEjeYGrande.push((1-almacenGrandeUso.to_f/almacenGrandeTotal.to_f).to_s)
    @stockEjeYChica.push((almacenChicoUso.to_f/almacenChicoTotal.to_f).to_s)
    @stockEjeYChica.push((1-almacenChicoUso.to_f/almacenChicoTotal.to_f).to_s)
    @stockEjeYRecepcion.push((recepcionUso.to_f/recepcionTotal.to_f).to_s)
    @stockEjeYRecepcion.push((1-recepcionUso.to_f/recepcionTotal.to_f).to_s)
    @stockEjeYDespacho.push((despachoUso.to_f/despachoTotal.to_f).to_s)
    @stockEjeYDespacho.push((1-despachoUso.to_f/despachoTotal.to_f).to_s)
    @stockEjeYPulmon.push((pulmonUso.to_f/pulmonTotal.to_f).to_s)
    @stockEjeYPulmon.push((1-pulmonUso.to_f/pulmonTotal.to_f).to_s)        
  end
  
  def recibirStock
    Thread.new do
        inv = Inventario.new
        inv.definirVariables
        inv.moverInventario(8,200,"571262aaa980ba030058a1f1","571262aaa980ba030058a1f3")
    end
  end

  def insertPromotion
    sm = SocialMedium.new
    sm.insertPromotionSpree(55,1500,"2016-01-01 00:00:00","2016-08-08 00:00:00","webeta")
  end
end
