module Spree
  class Promotion
    module Actions
      class DescuentoProducto < Spree::PromotionAction

        def perform(options={})
          Rails.logger.debug( "precioNuevo: "+precioNuevo.to_s )
          Rails.logger.debug( "idProducto: "+idProducto.to_s )
          Rails.logger.debug( "precioNuevo: "+options.to_s )
        end
      end
    end
  end
end