module FacturarHelper

# idfactura = 5727e3efc1ff9b0300019b3d
#idoc =57270b94ba0c0f0300c51bef


include ApplicationHelper 


### ve si la factura es correcta y la paga
def analizarFactura(id)
    error = false
    factura = JSON.parse(obtenerFactura(id))
    if factura[0] == nil
      return false      
    end
    if factura[0]["param"] == "id"
      return false
    end   
    idoc = factura[0]["oc"]
    oc = JSON.parse(obtenerOrdenDeCompra(idoc))

    if factura[0]["total"].to_i != oc[0]["precioUnitario"].to_i * oc[0]["cantidad"].to_i
        return false
    end
    ######### Esto debe ser activado antes de enviar IMPORTANTE
    #if factura[0]["cliente"] != idGrupo
    #    return false
    #end
    
    response = pagarFactura(factura)
    ## Falta confirmar si se pago correctamente
    Thread.new do
        avisarTransferencia(factura,response)
    end
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
    #url = "http://localhost:3002/api/pagos/recibir/" + response["_id"] + "?idfactura=" + factura[0]["_id"]
    url = "http://integra" + nOtroGrupo.to_s + ".ing.puc.cl/api/pagos/recibir/" + response["_id"] + "?idfactura=" + factura[0]["_id"]

    ans = httpGetRequest(url ,nil)
    Rails.logger.debug("debug::" + ans)
  
  end
end