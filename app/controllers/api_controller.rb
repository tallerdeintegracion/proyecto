class ApiController < ApplicationController

  include	ApplicationHelper
  include ReceiveOrdersHelper
  include PagosHelper
  include FacturarHelper
  
  layout false

  def inventarioConsultar

    inventario = JSON.parse(getSKUWithStock("571262aaa980ba030058a1f3"))
    cantidadJSON = inventario.find { |h1| h1["_id"] == params["sku"] }
    cantidad = 0
    if cantidadJSON != nil
      cantidad = cantidadJSON["total"]
    end
    render :json => {:sku => params[:sku], :cantidad => cantidad }
  end

  def facturarRecibir
    id = params[:id]
    result = analizarFactura(id)
    render :json => {:validado => result, :factura => id}    
  end

  def pagoRecibir
    id = params[:id]
    result = analizarPago(id)
    render :json => {:validado => result, :trx => id}
  end

  def ocRecibir
    id = params[:id]
    result = analizarOC(id)  
    render :json => {:aceptado => result, :idoc => id}  #el false debiera se result
  end
end
