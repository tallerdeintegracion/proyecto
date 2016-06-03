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
      ary = [5, 0, 0, 0,0,0] 37,116
      #despacharLista(ary, false123 , 37116 , idOc)
      render :text => "holia"
  end


end
