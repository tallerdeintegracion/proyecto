module Spree
  CheckoutController.class_eval do
    def edit
      @payment = @order.payments.order(:id).last
=begin
        trx_id             = @payment.webpay_trx_id
        amount             = @order.webpay_amount
        success_url        = webpay_success_url(:protocol => "http")
        failure_url        = webpay_failure_url(:protocol => "http")
        provider = payment_method.provider.new
=end
       if params[:state] == "checkout"
        payment_method     = @order.payment_method

        response = payment_method.pay(amount, @order.number)

        respond_to do |format|
          format.html { render text: response }
        end

      end
    end
  end
end