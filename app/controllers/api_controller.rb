class ApiController < ApplicationController
  
  layout false

  def documentacion

  end  
  ## Endpoint de /api/consultar/:id
  def inventarioConsultar
    
    sist = Sistema.new

    cantidad = sist.getStockSKUDisponible(params[:sku])
    render :json => { :stock => cantidad,:sku => params[:sku] }
  end

  ## Endpoint de /api/facturas/recibir/:id
  def facturarRecibir
    id = params[:id]
    ocClass = Oc.new
    result = ocClass.analizarFactura(id)
    render :json => {:validado => result, :idfactura => id}    
  end

  ## Endpoint de /api/pagos/recibir/:id?idfactura=xxxxx
  def pagoRecibir
  
    ocClass = Oc.new
    sist = Sistema.new
    invent = Inventario.new
    Rails.logger.debug("debug:: transferencia recibida")
    idPago = params[:id]
    idFactura = params[:idfactura]
    result = ocClass.analizarPago(idPago,idFactura)
    Thread.new do
      Rails.logger.debug("debug:: intentamos despachar")
      ## Gatillamos el envio desde aqui si es posible?
      if result == true
        res = invent.verSiEnviar(idFactura)
      end
      nOtroGrupo = Grupo.find_by(factura: idFactura)["nGrupo"]
      url = "http://localhost/api/despacho/recibir/" + fact["_id"]
      #url = "http://integra" + nOtroGrupo.to_s + ".ing.puc.cl/api/despacho/recibir/" + idFactura
      ans = sist.httpGetRequest(url ,nil)
      Rails.logger.debug("debug:: le avisamos al otro grupo")


    end
    render :json => {:validado => result, :idtrx => idPago}
  end

  ## Endpoint de /api/oc/recibir/:id Debe comprobar la oc antes de enviar al metodo compartido con los ftp
  def ocRecibir
    id = params[:id]
    
    sist = Sistema.new
    oc = JSON.parse(sist.obtenerOrdenDeCompra(id))
    if oc[0] == nil
      render :json => {:aceptado => false, :idoc => id} 
      return
    end
    if oc[0]["param"] == "id"
      render :json => {:aceptado => false, :idoc => id} 
      return
    end
    ocDB = Oc.find_by(oc: id)   
    if ocDB != nil
      render :json => {:aceptado => false, :idoc => id} 
      return

    end
    ocClass = Oc.new
    result = ocClass.analizarOC(id)      
    render :json => {:aceptado => result, :idoc => id} 
    
    Thread.new do
      sist = Sistema.new
      Rails.logger.debug("debug:: generamos la factura")

      fact = JSON.parse(sist.emitirFactura(id))
      ocDB = Oc.find_by(oc: id)   
      
      Rails.logger.debug("debug:: la agregamos al sistema de nosotros")
      ocDB.update(factura: fact["_id"])
      Rails.logger.debug("debug:: buscamos al otro grupo")

      nOtroGrupo = Grupo.find_by(idGrupo: oc[0]["cliente"])["nGrupo"]
      url = "http://localhost:8080/api/facturas/recibir/" + fact["_id"]
      #url = "http://integra" + nOtroGrupo.to_s + ".ing.puc.cl/api/facturas/recibir/"  + fact["_id"]
      Rails.logger.debug("debug:: le avisamos al otro grupo")

      ans = sist.httpGetRequest(url ,nil)
    end
    
  end
  
  ## Endpoint de /api/despacho/recibir/:id Debe comprobar la oc antes de enviar al metodo compartido con los ftp
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
