module Spree
  class Gateway::Integracionpay < Gateway
    
=begin
    preference :login, :string
    preference :password, :string
    preference :signature, :string
    preference :server, :string, default: 'sandbox'
    preference :solution, :string, default: 'Mark'
    preference :landing_page, :string, default: 'Billing'
    preference :logourl, :string, default: ''
=end
    def supports?(source)
      true
    end
=begin    
    # Indicates whether its possible to capture the payment
    def can_capture?(payment)
      ['checkout', 'pending'].include?(payment.state)
    end
=end
    def auto_capture?
      true
    end

    def provider_class
      ActiveMerchant::Billing::IntegracionpayGateway
    end

    def method_type
      'integracionpay'
    end
    
    def capture(*)
        logger.debug "Entro a capture"
        ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end
    def purchase(amount, checkout, gateway_options={})
        logger.debug "se entro al pago"
        ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end

    def authorize(money, checkout, options = {})
        logger.debug "se entro a autorizar"
        ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end

  end
end
