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

  #def dashboard
    
=begin 
      @data = {
      labels: ["January","February","March","April","May","June","July"],
      datasets: [
              {
                  fillColor: "rgba(220,220,220,0.5)",
                  strokeColor: "rgba(220,220,220,1)",
                  pointColor: "rgba(220,220,220,1)",
                  pointStrokeColor: "#fff",
                  data: [65,59,90,81,56,55,40]
              },
              {
                  fillColor: "rgba(151,187,205,0.5)",
                  strokeColor: "rgba(151,187,205,1)",
                  pointColor: "rgba(151,187,205,1)",
                  pointStrokeColor: "#fff",
                  data: [28,48,40,19,96,27,100]
              }
          ]
      }
      @options = {}

      #<%= line_chart @data, @options %>
=end

      #render :text => "dashboard"
  #end

  def datosDashboard

    @data = {
      labels: ["January","February","March","April","May","June","July"],
      datasets: [
              {
                  fillColor: "rgba(220,220,220,0.5)",
                  strokeColor: "rgba(220,220,220,1)",
                  pointColor: "rgba(220,220,220,1)",
                  pointStrokeColor: "#fff",
                  data: [65,59,90,81,56,55,40]
              },
              {
                  fillColor: "rgba(151,187,205,0.5)",
                  strokeColor: "rgba(151,187,205,1)",
                  pointColor: "rgba(151,187,205,1)",
                  pointStrokeColor: "#fff",
                  data: [28,48,40,19,96,27,100]
              }
          ]
      }
      @options = {}
      
  end

end
