class ApiController < ApplicationController

  include	ApplicationHelper
  include ReceiveOrdersHelper
  include PagosHelper
  include FacturarHelper
  include InventarioHelper

  
  layout false

  def documentacion

  end  
  ## Endpoint de /api/consultar/:id
  def inventarioConsultar

    cantidad = getStockSKUDisponible(params[:sku])
    render :json => { :stock => cantidad,:sku => params[:sku] }
  end

  ## Endpoint de /api/facturas/recibir/:id
  def facturarRecibir
    id = params[:id]
    result = analizarFactura(id)
    render :json => {:validado => result, :idfactura => id}    
  end

  ## Endpoint de /api/pagos/recibir/:id?idfactura=xxxxx
  def pagoRecibir
      Rails.logger.debug("debug:: transferencia recibida")
    idPago = params[:id]
    idFactura = params[:idfactura]
    result = analizarPago(idPago,idFactura)
    Thread.new do
      Rails.logger.debug("debug:: intentamos despachar")
      ## Gatillamos el envio desde aqui si es posible?
      verSiEnviar(idFactura)
    end
    render :json => {:validado => result, :idtrx => idPago}
  end

  ## Endpoint de /api/oc/recibir/:id Debe comprobar la oc antes de enviar al metodo compartido con los ftp
  def ocRecibir
    id = params[:id]

    oc = JSON.parse(obtenerOrdenDeCompra(id))
    if oc[0] == nil
      render :json => {:aceptado => false, :idoc => id} 
      return
    end
    if oc[0]["param"] == "id"
      render :json => {:aceptado => false, :idoc => id} 
      return
    end   
    result = analizarOC(id)      
    render :json => {:aceptado => result, :idoc => id} 
    
    Thread.new do
      fact = JSON.parse(emitirFactura(id))
      ocBD = Oc.find_by(oc: id)
      ocBD.update(factura: fact["_id"])
      nOtroGrupo = Grupo.find_by(idGrupo: oc[0]["cliente"])["nGrupo"]
      url = "http://localhost/api/facturas/recibir/" + fact["_id"]
      #url = "http://integra" + nOtroGrupo.to_s + ".ing.puc.cl/api/pagos/recibir/" + response["_id"] + "?idfactura=" + factura[0]["_id"]

      ans = httpGetRequest(url ,nil)
    end
    
  end
  def despachoRecibir
    idFactura = params[:id]
    
    ocBD = Oc.findBy(factura: idFactura)
    
    if ocBD == nil
      render :json => {:validado => false} 
      return
    end
    
    ## Gatilla el recibir los productos
    ####################################
    
    if ans > ocBD.cantidad
      render :json => {:validado => true} 
      return
    end
    render :json => {:validado => false} 
  end
end
