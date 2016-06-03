class IntegracionpayController < ApplicationController

   layout false
   
   def pay
      val = params[:orderid]
      sist = Sistema.new
      ord = ::Spree::Order.find_by(number: val.to_s)
      ### TODO ver si hay stock ###
      
      
      products = ::Spree::LineItem.where(order_id: ord["id"])
      skuTrabajados = [8, 6, 14, 31, 49, 55] #están en orden según el id de spree
      checkStock = [0,0,0,0,0,0]
      products.each do |prod|
        checkStock[prod["variant_id"]] = prod["quantity"]
      end
      
      inv = Inventario.new
      
      res = inv.reservarStock(checkStock)     
      #res = true
      if(!res)
        redirect_to "/", :alert => "No hay suficiente stock"
        return
      end
      
      puts ord.to_json.to_s
      bol = sist.emitirBoleta(ord[:user_id],ord[:total].to_i)
      boleta = JSON.parse(bol)
      Boletum.find_or_create_by(boleta_id: boleta["_id"].to_s, orden_id: val.to_s, estado: "Creada", total: ord["total"].to_i)
      
      redirect_to "http://integracion-2016-dev.herokuapp.com/web/pagoenlinea?callbackUrl=http%3A%2F%2Flocalhost%3A8080%2Fintegracionpay%2Fconfirm/"+boleta["_id"].to_s+"&cancelUrl=http%3A%2F%2Flocalhost%3A8080%2Fintegracionpay%2Fcancel/"+boleta["_id"].to_s+"&boletaI
d="+boleta["_id"].to_s
      return
   end

    def confirm
        puts "Entró a confirmado"

        boleta = Boletum.find_by(boleta_id: params[:id])
        
        ## No puedo buscar una boleta creada?
        
        boleta.update(estado: "Aceptada")
        ## TODO aceptar la boleta en spree
        ord = ::Spree::Order.find_by(number: boleta["orden_id"].to_s)
        ord.update(state: "complete", completed_at: Time.now, payment_total: ord["total"], payment_state: "paid" )
        ::Spree::Payment.find_or_create_by(amount: ord["total"], order_id: ord["id"], payment_method_id: 12, state: "completed", number: "PM20A70L") 
        
        redirect_to "/orders/"+boleta["orden_id"], :notice => "La orden fue pagada exitosamente"

    end





    def cancel
        
        
        boleta = Boletum.find_by(boleta_id: params[:id])
        puts boleta.to_json.to_s
        boleta.update(estado: "Cancelada")
        ord = ::Spree::Order.find_by(number: boleta["orden_id"].to_s)
        ord.update(state: "canceled")
        ord.update(canceled_at: Time.now)

    
        redirect_to "/", :alert => "El pago fue cancelado"
    end
end
