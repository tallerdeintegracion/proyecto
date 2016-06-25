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

    social = SocialMedium.new
    social.searchMessages
    #social.sendMessageUrl
    #social.publishToSocialMedia("8" , 990, "25/06/2016", "23/06/2016" , "codigopromo123 " )
    render :text => "Search for messages Method"

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

  def recibirStock
    Thread.new do
        inv = Inventario.new
        inv.definirVariables
        inv.moverInventario(31,1503,"571262aaa980ba030058a23d","571262aaa980ba030058a1f3")
    end
  end

end
