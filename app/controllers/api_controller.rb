class ApiController < ApplicationController

  include	ApplicationHelper
  include ReceiveOrdersHelper
  include PagosHelper
  include FacturarHelper
  
  layout false

  ## Endpoint de /api/consultar/:id
  def inventarioConsultar

    inventario = JSON.parse(getSKUWithStock("571262aaa980ba030058a1f3"))
    cantidadJSON = inventario.find { |h1| h1["_id"] == params["sku"] }
    cantidad = 0
    if cantidadJSON != nil
      cantidad = cantidadJSON["total"]
    end
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
    idPago = params[:id]
    idFactura = params[:idfactura]
    result = analizarPago(idPago,idFactura)
    ## Gatillamos el envio desde aqui si es posible?
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
    ans = recibirMateriasPrimas(ocBD.sku, bodegaRecepcion, bodegaPrincipal)

    if ans > ocBD.cantidad
      render :json => {:validado => true} 
      return
    end
    render :json => {:validado => false} 
  end
end