class Oc < ActiveRecord::Base

## Ambiente actual: dev
## Modificar en l34,l165,l240

def recibirOC(id)

    sist = Sistema.new
    oc = JSON.parse(sist.obtenerOrdenDeCompra(id))
    if oc[0] == nil
      return false
    end
    if oc[0]["param"] == "id"
      return false
    end
    ocDB = Oc.find_by(oc: id)   
    if ocDB != nil
      return false
    end
    result = analizarOC(id)      
    
    Thread.new do
      sist = Sistema.new
      Rails.logger.debug("debug:: generamos la factura")

      fact = JSON.parse(sist.emitirFactura(id))
      ocDB = Oc.find_by(oc: id)   
      
      Rails.logger.debug("debug:: la agregamos al sistema de nosotros")
      ocDB.update(factura: fact["_id"])
      Rails.logger.debug("debug:: buscamos al otro grupo")

      nOtroGrupo = Grupo.find_by(idGrupo: oc[0]["cliente"])["nGrupo"]
      url = "http://localhost:3000/api/facturas/recibir/" + fact["_id"]
      #url = "http://integra" + nOtroGrupo.to_s + ".ing.puc.cl/api/facturas/recibir/"  + fact["_id"]
      Rails.logger.debug("debug:: le avisamos al otro grupo")

      ans = sist.httpGetRequest(url ,nil)
    end
    return result
end

def analizarOC(id)
	require 'json'
    #puts "oc cantidad: "+ oc[0]['cantidad'].to_s+ " . oc sku: "+ oc[0]['sku'].to_s+"\n"
  
  #puts "------ Iniciando el analisis de la oc "
  sist = Sistema.new
  oc = JSON.parse(sist.obtenerOrdenDeCompra(id))
  if oc.nil?
      return false
  end  

  sku = oc[0]['sku'].to_s
  cantidad = oc[0]['cantidad'].to_s
  canal = oc[0]['canal'].to_s

  oc_db = Oc.find_by(oc: id)  
    #oc_db.update(estados: 'creada')
  if oc_db.nil? #si es nula se crea más abajo          
  elsif oc_db != nil #si es que preguntan de nuevo, ya no se procesa
   # puts "------ La oc ya havia sido procesada"
  	return false
  end    
  		#SE ASUME QUE QUE SÍ SE PUEDEN TRABAJAR SKU QUE NO PRODUZCA, SIEMPRE QUE TENGA. 
	    #se validará que se tenga stock por ahora para satisfacer el pedido, sino se tiene se rechaza:
	    stock = sist.getStockSKUDisponible(sku)#@bodegaPrincipal)
	    puts "### Stock del sku " + sku.to_s + " es de " + stock.to_s + " y piden "+cantidad.to_s+"\n"
	    if cantidad.to_i > stock.to_i
	      #se anula la oc
	      sist.rechazarOrdenDeCompra(id, "No tenemos aún el sku requerido")
	      
          Oc.find_or_create_by(oc: id , estados: "rechazada", canal: canal, factura: "", pago: "", sku: sku, cantidad: cantidad)#los estados son: defectuosa, aceptada, rechazada
	      
	      #Oc.find_by(oc: id).update(estados: 'rechazada')
	      puts "oc " + id.to_s + " rechazada por falta de stock "+"\n"
	      return false
	    else
		      	  #se continúa con la oc, aceptando y dando la factura
			      oc_aceptada = JSON.parse(sist.recepcionarOrdenDeCompra(id)) #este método acepta la orden de compra
			      if oc_aceptada.nil?
			          Oc.find_or_create_by(oc: id , estados: "rechazada", canal: canal, factura: "", pago: "", sku: sku, cantidad: cantidad)#los estados son: defectuosa, aceptada, rechazada
			          puts "oc " + id.to_s + " rechazada por error al recepcionarOrdenDeCompra "+"\n"	
			          return false
			      end 

			      Oc.find_or_create_by(oc: id , estados: "aceptada", canal: canal, factura: "", pago: "", sku: sku, cantidad: cantidad)#los estados son: defectuosa, aceptada, rechazada
			      #Oc.find_by(oc: id).update(estados: 'aceptada')    
			      #YA NO MUEVE STOCK, SINO QUE ACTUALIZA LA TABLA SKUS
			      fila_sku = Sku.find_by(sku: sku.to_s)
			      reservado = fila_sku["reservado"]
			      #nuevo_reservado = reservado.to_i + cantidad.to_i
			      #fila_sku.update(reservado: nuevo_reservado)
            fila_sku.increment!(:reservado, cantidad.to_i)
            fila_sku = Sku.find_by(sku: sku.to_s)
			      reservado1 = fila_sku["reservado"]
			      puts "antiguo reservado " + reservado.to_s + " nuevo reservado " + reservado1.to_s + " sku " + sku.to_s + "\n"  
			      
            #####################################################
            #AL ACEPTAR LA OC SE ACTUALIZA EL STOCK EN SPREE:
            Inventario.new.updateStockSpree()
            #####################################################
            return true
		      #end	      
	    end
	 
	#nunca debería llegar a este punto
    return true
end

### ve si la factura es correcta y la paga
def analizarFactura(id)
    sist = Sistema.new;
    ## Comprobamos que la factura exista
    factura = JSON.parse(sist.obtenerFactura(id))
    if factura[0] == nil
      return false      
    end
    if factura[0]["param"] == "id"
      return false
    end   
    
    ## Obtenemos la oc correspondiente al a factura
    idoc = factura[0]["oc"]
    oc = JSON.parse(sist.obtenerOrdenDeCompra(idoc))
    
    ## Vemos que calzen los totales y que sea para nosotros
    if factura[0]["total"].to_i != oc[0]["precioUnitario"].to_i * oc[0]["cantidad"].to_i
        return false
    end
    if factura[0]["cliente"] != sist.idGrupo
        return false
    end
    
    ##Confirmamos que no la hayamos pagado ya
    oc = SentOrder.find_by(oc: idoc)

    if oc == nil
      return false
    end
    if oc["estado"] == "Pagada"
      return false
    end

    response = pagarFactura(factura)
    ## Falta confirmar si se pago correctamente
    Thread.new do
        avisarTransferencia(factura,response)
    end
    ## Actualizamos la oc
    oc.update(estado: "Pagada")
    return true
  end
  
  ## Solo paga la factura
  def pagarFactura(factura)
    sist = Sistema.new;
    proveedor = Grupo.find_by(idGrupo: factura[0]["proveedor"])["idBanco"]
    response = JSON.parse(sist.transferir(factura[0]["total"],sist.idBanco,proveedor))
    return response
  end
  
  ## Este metodo avisa al otro grupo que se realizó la transferencia, si en la bd no esta grupos.idGrupo se cae
  def avisarTransferencia(factura,response)
    sist = Sistema.new
    nOtroGrupo = Grupo.find_by(idGrupo: factura[0]["proveedor"])["nGrupo"]
    url = "http://localhost:3000/api/pagos/recibir/" + response["_id"] + "?idfactura=" + factura[0]["_id"]
    #url = "http://integra" + nOtroGrupo.to_s + ".ing.puc.cl/api/pagos/recibir/" + response["_id"] + "?idfactura=" + factura[0]["_id"]
    Rails.logger.debug("debug:: se avisa la transferencia")

    ans = sist.httpGetRequest(url ,nil)
  
  end

 ## Comprueba el pago y actualiza la oc si es correcto
  def analizarPago(idPago, idFactura)
    sist = Sistema.new
    pago = JSON.parse(sist.obtenerTransaccion(idPago))
    Rails.logger.debug("debug:: Se obtuvo el pago")
    ## Vemos que el pago exista
    if pago[0] == nil
      return false      
    end
    if pago[0]["param"] == "id"
      return false
    end
    Rails.logger.debug("debug:: Pago existe")
    ## Vemos que la factura exista
    factura = JSON.parse(sist.obtenerFactura(idFactura))
    if factura[0] == nil
      return false      
    end
    if factura[0]["param"] == "id"
      return false
    end   
    Rails.logger.debug("debug:: Factura existe")

    ## Obtenemos la orden de compra de la factura (asumimos que existe)
    idoc = factura[0]["oc"]
    oc = JSON.parse(sist.obtenerOrdenDeCompra(idoc))
    Rails.logger.debug("debug:: Orden de Compra obtenida")

    ## Comprobamos que el monto sea el correcto
    if factura[0]["total"].to_i != pago[0]["monto"].to_i
      return false
    end
    Rails.logger.debug("debug:: Monto Correcto")

    ## Comprobamos que seamos el destinatario del pago
    if pago[0]["destino"] != sist.idBanco
      return false
    end
    Rails.logger.debug("debug:: Destinatario Correcto")

    ## Vemos que ese pago no estuviera ya ingresado
    oc = Oc.find_by(pago: idPago)
    if oc != nil
        return false
    end
    sist.facturaPagada(idFactura)
    Rails.logger.debug("debug:: El pago es nuevo, se marcó en el sistema como ")

    
    ## Actualizamos la oc
    ocBD = Oc.find_by(oc: idoc)
    
    ## La OC es de otro?
    if ocBD == nil
      return false
    end
    
    ocBD.update(estados: "Pagada")
    ocBD.update(pago: idPago)
    Rails.logger.debug("debug:: Datos actualizados")
    
    invent = Inventario.new    
    invent.definirVariables
    Thread.new do
      Rails.logger.debug("debug:: intentamos despachar")
      ## Gatillamos el envio desde aqui si es posible?
      res = invent.verSiEnviar(idFactura)
      #nOtroGrupo = Grupo.find_by(factura: idFactura)["nGrupo"]
      #url = "http://localhost:3000/api/despacho/recibir/" + fact["_id"]
      #url = "http://integra" + nOtroGrupo.to_s + ".ing.puc.cl/api/despacho/recibir/" + idFactura
      #ans = sist.httpGetRequest(url ,nil)
      #Rails.logger.debug("debug:: le avisamos al otro grupo")


    end    
  end

end
