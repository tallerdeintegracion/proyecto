require 'rest_client'
module Spree
  class Gateway::Integracionpay < Gateway
    #preference :merchant_id_no, :string
    #preference :access_code, :string
    #preference :secure_secret, :string

    def auto_capture?
      false
    end

    # Spree usually grabs these from a Credit Card object but when using
    # Commbank's 3 Party where we wouldn't keep the credit card object
    # as that's entered outside of the store forms
    def actions
      %w{capture}
    end

    # Indicates whether its possible to void the payment.
    def can_void?(payment)
      !payment.void?
    end

    # Indicates whether its possible to capture the payment
    def can_capture?(payment)
      payment.pending? || payment.checkout?
    end

    def method_type
      'integracionpay'
    end

    def capture(*args)
     # ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end

    def source_required?
      false
    end

    def provider_class
      self.class
    end

    def provider
      self
    end

    def purchase
        # This is normally delegated to the payment, but don't do that. Handle it here.
        # This is a hack copied from the Spree Better Paypal Express gem.
        Class.new do
          def success?; true; end
          def authorization; nil; end
        end.new
    end
    def authorize
        # This is normally delegated to the payment, but don't do that. Handle it here.
        # This is a hack copied from the Spree Better Paypal Express gem.
        Class.new do
          def success?; true; end
          def authorization; nil; end
        end.new
    end


=begin 
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
=end
  end
end
