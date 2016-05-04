module InventarioHelper

  def verSiEnviar(idFactura)
    sku = OC.find_by(factura: idFactura)["sku"]
    idOC = OC.find_by(factura: idFactura)["oc"]
    return false
    ### Pipo lo hace
    #
    #
    #
    #
    despacharOC(idOC) 
  end
  
  def despacharOC(idOC)
    ## Pega de benja
  end

end
