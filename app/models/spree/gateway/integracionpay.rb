require 'rest_client'
module Spree
  class Gateway::Integracionpay < Gateway
    
    def provider_class
      Gateway::Integracionpay
    end
      def authorize(money, credit_card_or_referenced_id, options = {})
        puts "OK"
        result = RestClient.get "http://url?id=1sdfawd"
      end

      def purchase(money, credit_card_or_referenced_id, options = {})
        puts "OK"
      end

      def method_type
        'integracionpay'
      end
      # Indicates whether its possible to capture the payment
      def can_capture?(payment)
        payment.pending? || payment.checkout?
      end
      
      def capture(money_cents, response_code, gateway_options)
        gateway_order_id   = gateway_options[:order_id]
        order_number       = gateway_order_id.split('-').first
        payment_identifier = gateway_order_id.split('-').last
        payment = Spree::Payment.find_by(number: payment_identifier)
        order   = payment.order
        ActiveMerchant::Billing::Response.new(true,  "Aprobado", {}, {})
      end
      def actions
        %w{capture}
      end
      
      def pay(amount, id) 
        result = RestClient.get "http://url?id=1sdfawd"        
      end
      
  end
end
