class HomeController < ApplicationController
  
  layout false
  
  def index
    social = SocialMedium.new
    social.publishToSocialMedia("8" , 990, "25/06/2016", "23/06/2016" , "codigopromo123 " )
    render :text => "Search for messages Method"

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
      render :text => "holia"
  end

  def datosDashboard

      @pieData = [
      {
          value: 20,
          color:"#878BB6"
      },
      {
          value: 40,
          color: "#4ACAB4"
      },
      {
          value: 10,
          color: "#FF8153"
      },
      {
          value: 30,
          color: "#FFEA88"
      }
      ];
      #@options = {}
      render :text => "hola"
  end

end
