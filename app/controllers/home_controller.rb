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
    social = SocialMedium.new
    social.searchMessages
    #social.sendMessageUrl
    #social.publishToSocialMedia("8" , 990, "25/06/2016", "23/06/2016" , "codigopromo123 " )
    render :text => "Search for messages Method"
    
  end


end
