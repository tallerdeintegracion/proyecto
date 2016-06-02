class IntegracionpayController < ApplicationController

   layout false
   
   def pay
      val = params[:orderid]
      sist = Sistema.new
      ord = ::Spree::Order.find_by(number: val.to_s)
      ### TODO ver si hay stock ###
      
      products = ::Spree::LineItem.find_by(order_id: ord[:id].to_s)

      inv = Inventario.new
      
      #res = inv.reservarStock()     
      res = true
      if(!res)
        redirect_to "/"
      end
      
      puts ord.to_json.to_s
      boleta = sist.emitirBoleta(ord[:user_id],ord[:total].to_i)
      
      Boletum.find_or_create_by(boleta_id: boleta["_id"].to_s, orden_id: val.to_s, estado: "Creada", total: ord["total"].to_i)
      
      redirect_to "http://integracion-2016-dev.herokuapp.com/web/pagoenlinea?callbackUrl=http%3A%2F%2Flocalhost%3A8080%2Fintegracionpay%2Fconfirm&cancelUrl=http%3A%2F%2Flocalhost%3A8080%2Fintegracionpay%2Fcancel&boletaI
d="+JSON.parse(boleta)["_id"].to_s
   end

    def confirm
        puts "Entró a confirmado"


        boleta = Boletum.find_by(estado: "Creada")
        boleta.update(estado: "Aceptada")
        ## TODO aceptar la boleta en spree
        redirect_to "/orders/"+boleta["orden_id"]

    end

    def cancel
        puts "Entro a Cancelado"
        
        
        boleta = Boletum.find_by(estado: "Creada")
        boleta.update(estado: "Cancelada")
    
        redirect_to "/orders/"+boleta["orden_id"]
    end
end
