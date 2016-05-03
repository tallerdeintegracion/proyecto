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
    render :json => {:sku => params[:sku], :cantidad => cantidad }
  end

  ## Endpoint de /api/facturas/recibir/:id
  def facturarRecibir
    id = params[:id]
    result = analizarFactura(id)
    render :json => {:validado => result, :factura => id}    
  end

  ## Endpoint de /api/pagos/recibir/:id?idfactura=xxxxx
  def pagoRecibir
    idPago = params[:id]
    idFactura = params[:idfactura]
    #@output = params
    result = analizarPago(idPago,idFactura)
    render :json => {:validado => result, :trx => id}
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
  end
end
