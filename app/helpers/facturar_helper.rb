module FacturarHelper


include ApplicationHelper 


### ve si la factura es correcta y la paga
def analizarFactura(id)

    ## Comprobamos que la factura exista
    factura = JSON.parse(obtenerFactura(id))
    if factura[0] == nil
      return false      
    end
    if factura[0]["param"] == "id"
      return false
    end   
    
    ## Obtenemos la oc correspondiente al a factura
    idoc = factura[0]["oc"]
    oc = JSON.parse(obtenerOrdenDeCompra(idoc))
    
    ## Vemos que calzen los totales y que sea para nosotros
    if factura[0]["total"].to_i != oc[0]["precioUnitario"].to_i * oc[0]["cantidad"].to_i
        return false
    end
    if factura[0]["cliente"] != idGrupo
        return false
    end
    
    ##Confirmamos que no la hayamos pagado ya
    oc = SentOrder.find_by(oc: idoc)
    if oc["estado"] == "Pagada"
        return false
    end
    
    response = pagarFactura(factura)
    ## Falta confirmar si se pago correctamente
    Thread.new do
        avisarTransferencia(factura,response)
    end
    ## Actualizamos la oc
    ocBD = SentOrder.find_by(oc: idoc)
    ocBD.update(estado: "Pagada")
    return true
  end
  
  ## Solo paga la factura
  def pagarFactura(factura)
    proveedor = Grupo.find_by(idGrupo: factura[0]["proveedor"])["idBanco"]
    response = JSON.parse(transferir(factura[0]["total"],idBanco,proveedor))
    return response
  end
  
  ## Este metodo avisa al otro grupo que se realizó la transferencia, si en la bd no esta grupos.idGrupo se cae
  def avisarTransferencia(factura,response)
    nOtroGrupo = Grupo.find_by(idGrupo: factura[0]["proveedor"])["nGrupo"]
    url = "http://localhost/api/pagos/recibir/" + response["_id"] + "?idfactura=" + factura[0]["_id"]
    #url = "http://integra" + nOtroGrupo.to_s + ".ing.puc.cl/api/pagos/recibir/" + response["_id"] + "?idfactura=" + factura[0]["_id"]
    Rails.logger.debug("debug:: se avisa la transferencia")

    ans = httpGetRequest(url ,nil)
  
  end
end