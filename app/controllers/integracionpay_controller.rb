class IntegracionpayController < ApplicationController
## Ambiente: prod 
## Cambiar: l44
   layout false
   
   def pay
      puts "Entramos al pago"
      val = params[:orderid]
      sist = Sistema.new
      ord = ::Spree::Order.find_by(number: val.to_s)
      ### TODO ver si hay stock ###
      puts "Encontramos la orden"
      
      
      products = ::Spree::LineItem.where(order_id: ord["id"]).order("variant_id DESC")
      puts "Entramos los productos"

      skuTrabajados = [8, 6, 14, 31, 49, 55] #están en orden según el id de spree
      checkStock = [0,0,0,0,0,0]
      products.each do |prod|
        checkStock[prod["variant_id"]-1] = prod["quantity"]
      end
      
      inv = Inventario.new
      
      res = inv.listaSkuDisponible(checkStock)     
      #res = true
      if(!res)
        redirect_to "/spree/", :alert => "No hay suficiente stock"
        return
      end
      #userId = ord[:user_id]
      #if ord[:user_id] == nil
      #  userId = 0
      #end

      puts ord.to_json.to_s
      bol = sist.emitirBoleta(3,ord[:total].to_i)
      boleta = JSON.parse(bol)
      Boletum.find_or_create_by(boleta_id: boleta["_id"].to_s, orden_id: val.to_s, estado: "Creada", total: ord["total"].to_i)
      
      redirect_to "http://integracion-2016-prod.herokuapp.com/web/pagoenlinea?callbackUrl=http%3A%2F%2Fintegra3.ing.puc.cl%2Fintegracionpay%2Fconfirm%2F"+boleta["_id"].to_s+"&cancelUrl=http%3A%2F%2Fintegra3.ing.puc.cl%2Fintegracionpay%2Fcancel%2F"+boleta["_id"].to_s+"&boletaId="+boleta["_id"].to_s
      #redirect_to "http://integracion-2016-dev.herokuapp.com/web/pagoenlinea?callbackUrl=http%3A%2F%2Flocalhost%3A%0A3000%2Fintegracionpay%2Fconfirm%2F"+boleta["_id"].to_s+"&cancelUrl=http%3A%2F%2Flocalhost%3A%0A3000%2Fintegracionpay%2Fcancel%2F"+boleta["_id"].to_s+"&boletaId="+boleta["_id"].to_s
      return
   end

    def confirm
        puts "Entró a confirmado"

        boleta = Boletum.find_by(boleta_id: params[:id])
        
        ## Comprobamos de que la boleta sea nueva
        if boleta["estado"] != "Creada"
            redirect_to "/spree/", :alert => "El pago ya había sido realizado. El id de la boleta era "+boleta["boleta_id"].to_s
            return
        end
        boleta.update(estado: "Aceptada")

        ## Marcamos en spree que fue pagada
        ord = ::Spree::Order.find_by(number: boleta["orden_id"].to_s)
        ord.update(state: "complete", completed_at: Time.now, payment_total: ord["total"], payment_state: "paid" )
        ::Spree::Payment.find_or_create_by(amount: ord["total"], order_id: ord["id"], payment_method_id: 12, state: "completed", number: ::Spree::Payment.count) 
                
        ## Despachamos
        products = ::Spree::LineItem.where(order_id: ord["id"]).order("variant_id DESC")
        skuTrabajados = [8, 6, 14, 31, 49, 55] #están en orden según el id de spree
        despachoUnits = [0,0,0,0,0,0]
        products.each do |prod|
          despachoUnits[prod["variant_id"]-1] = prod["quantity"]
        end
        dir = ::Spree::Address.find_by(id: ord["ship_address_id"])
        direccion = dir["address1"]
        
        Rails.logger.info("Se entrara al thread de despacho")
        Thread.new do
            inv = Inventario.new
            Rails.logger.info("Se empezará el despacho")
            inv.despacharLista(despachoUnits, direccion, boleta["total"] , boleta["boleta_id"])
            inv.updateStockSpree()
            Rails.logger.info("Stock actualizado")
        end



        ## Redireccionamos a spree
        redirect_to "/spree/orders/"+boleta["orden_id"], :notice => "La orden fue pagada exitosamente. El id de la boleta es "+boleta["boleta_id"].to_s

    end





    def cancel
        
        
        boleta = Boletum.find_by(boleta_id: params[:id])
        puts boleta.to_json.to_s
        boleta.update(estado: "Cancelada")
        ord = ::Spree::Order.find_by(number: boleta["orden_id"].to_s)
        ord.update(state: "canceled")
        ord.update(canceled_at: Time.now)

    
        redirect_to "/spree/", :alert => "El pago fue cancelado. El id de la boleta era "+boleta["boleta_id"].to_s
    end
end
