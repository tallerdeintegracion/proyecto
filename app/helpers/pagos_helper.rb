module PagosHelper

  ## Comprueba el pago y actualiza la oc si es correcto
  def analizarPago(idPago, idFactura)
    pago = JSON.parse(obtenerTransaccion(idPago))
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
    factura = JSON.parse(obtenerFactura(idFactura))
    if factura[0] == nil
      return false      
    end
    if factura[0]["param"] == "id"
      return false
    end   
    Rails.logger.debug("debug:: Factura existe")

    ## Obtenemos la orden de compra de la factura (asumimos que existe)
    idoc = factura[0]["oc"]
    oc = JSON.parse(obtenerOrdenDeCompra(idoc))
    Rails.logger.debug("debug:: Orden de Compra obtenida")

    ## Comprobamos que el monto sea el correcto
    if factura[0]["total"].to_i != pago[0]["monto"].to_i
      return false
    end
    Rails.logger.debug("debug:: Monto Correcto")

    ## Comprobamos que seamos el destinatario del pago
    if pago[0]["destino"] != idBanco
      return false
    end
    Rails.logger.debug("debug:: Destinatario Correcto")

    ## Vemos que ese pago no estuviera ya ingresado
    oc = Oc.find_by(pago: idPago)
    if oc != nil
        return false
    end
    Rails.logger.debug("debug:: El pago es nuevo")

    
    ## Actualizamos la oc
    ocBD = Oc.find_by(oc: idoc)
    
    ## La OC es de otro?
    if ocBD == nil
      return false
    end
    
    ocBD.update(estados: "Pagada")
    ocBD.update(pago: idPago)
    Rails.logger.debug("debug:: Datos actualizados")
    
    return true
    
  end
end

#idOC = 5713613ea0aada03009160c6
#idFactura = 572906af9fda6e030047c890 total = 630960
#idPago = 572907609fda6e030047d232