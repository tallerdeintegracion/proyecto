module FacturarHelper

include ApplicationHelper 

def analizarFactura(id)
    error = false
    factura = JSON.parse(obtenerFactura(id))
    if factura[0] == nil
      return false      
    end
    idoc = factura[0]["oc"]
    oc = JSON.parse(obtenerOrdenDeCompra(idoc))

    if factura[0]["total"].to_i != oc[0]["precioUnitario"].to_i * oc[0]["cantidad"].to_i
        return false
    end
    
    #if factura[0]["cliente"] != idGrupo
    #    return false
    #end
    
    pagarFactura(factura, oc)
    ocBD = SentOrder.find_by(oc: idoc)
    ocBD.update(estado: "Pagada")
    return true
# idfactura = 5727e3efc1ff9b0300019b3d
#idoc =57270b94ba0c0f0300c51bef
  end
  
  def pagarFactura(factura, oc)
    #origen = 
    transferir(factura[0]["total"],origen,destion)
  end
end