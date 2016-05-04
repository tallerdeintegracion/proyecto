class ApiController < ApplicationController

  include	ApplicationHelper
  include ReceiveOrdersHelper
  include PagosHelper
  include FacturarHelper
  #include InventarioController
  
  layout false

  ## Endpoint de /api/consultar/:id
  def documentacion

  end  
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
    ## Gatillamos el generar la factura desde aqui?
    render :json => {:aceptado => result, :idoc => id} 
  end
  def despachoRecibir(id)
    idFactura = params[:id]
    
    ocBD = Oc.findBy(factura: idFactura)
    
    if ocBD == nil
      render :json => {:validado => false} 
      return
    end
    
    ## Gatilla el recibir los productos
    #ans = recibirMateriasPrimas(ocBD.sku, bodegaRecepcion, bodegaPrincipal)

    if ans > ocBD.cantidad
      render :json => {:validado => true} 
      return
    end
    render :json => {:validado => false} 
  end
end
