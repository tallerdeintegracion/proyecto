module Spree
  class PaypalController < StoreController

    def pay
      order = current_order || raise(ActiveRecord::RecordNotFound)
      items = order.line_items.map(&method(:line_item))

      additional_adjustments = order.all_adjustments.additional
      tax_adjustments = additional_adjustments.tax
      shipping_adjustments = additional_adjustments.shipping
      puts "Entro al pago"
    end

    def confirm
        puts "Entró a confirmado"
    end

    def cancel
        puts "Entro a Cancelado"
    end
  end
end