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
    idPago = params[:id]
    idFactura = params[:idfactura]
    result = ocClass.analizarPago(idPago,idFactura)
    render :json => {:validado => result, :idtrx => idPago}
  end

  ## Endpoint de /api/oc/recibir/:id Debe comprobar la oc antes de enviar al metodo compartido con los ftp
  def ocRecibir
    id = params[:id]
    ocClass = Oc.new
    result = ocClass.recibirOC(id)    
    render :json => {:aceptado => result, :idoc => id} 

  end
  
  ## Endpoint de /api/despacho/recibir/:id Debe comprobar la oc antes de enviar al metodo compartido con los ftp
  def despachoRecibir
    idFactura = params[:id]
    ocClass = Oc.new
    
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
