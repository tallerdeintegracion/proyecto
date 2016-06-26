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
      render :text => sist.obtenerCartola(1 , 1466899259, sist.idBanco)
  end
  
  def self.guardaSaldoDiario
      sist = Sistema.new
      Saldo.find_or_create_by(fecha:Time.now.to_date, monto: JSON.parse(sist.obtenerCuenta(sist.idBanco))[0]["saldo"])
  end

  def numBoletas date

      boletas = Boletum.where(" DATE(created_at) = ?" , date)
      puts "date "  + date.to_s
      puts "boldetas "  + boletas.to_s
      return boletas.count   
  end

  def montoBoletas date
     boletas = Boletum.where(" DATE(created_at) = ?" , date)
      puts "date "  + date.to_s
      puts "boldetas "  + boletas.to_s
      total  = 0 
      boletas.each do |row|

      end  
  end

  def dashboard
    

    sist = Sistema.new
    saldoActual = JSON.parse(sist.obtenerCuenta(sist.idBanco))[0]["saldo"]
    @diasEjeX = []
    @saldosEjeY = []
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
    end

    @diasEjeXBoletas = []
    @saldosEjeYBoletas = []
    for i in 0..13
       @diasEjeXBoletas.push((13-i).day.ago.to_date)  
   
            date = (13-i).day.ago.to_date
            num = numBoletas(date)
            puts "nume  " + num.to_s       
            @saldosEjeYBoletas.push(num)
                
       
    end
    
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
