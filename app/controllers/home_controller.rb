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
      ary = [50, 0, 40, 231,20,0] 
      inv.listaSkuDisponible(ary )
      render :text => "holia"
  end


end
