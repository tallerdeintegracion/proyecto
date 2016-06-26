module Spree
  class Calculator::ProductWithOptionValueCalculator < Calculator
    preference :product_price, :decimal, default: 0
    preference :idProducto, :string, default: 0

    def self.description
      'Descuento especial'
    end

    def compute(object = nil)
      sum = 0
      return 0 if object.nil?
      for line_item in object.line_items do
          Rails.logger.debug(line_item.variant_id.to_s)
          var = 0
          if line_item.variant_id.to_i == preferred_idProducto.to_i 
            var = (line_item.price - preferred_product_price) * line_item.quantity * 1.19
          end
          sum += var 
      end
      Rails.logger.debug(sum)
      sum
    end
  end
end

=begin
module Spree
  class Calculator::ProductWithOptionValueCalculator < Calculator
    preference :product_price, :decimal, default: 0

    def self.description
      'Change Product price'
    end

    def compute(line_item = nil)
      discount = line_item.quantity * preferred_product_price
      (line_item.price * line_item.quantity) - discount
    end
  end
end
=end