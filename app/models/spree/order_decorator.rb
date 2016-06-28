module Spree
  Order.class_eval do
  insert_checkout_step :confirm, :after => :payment
  insert_checkout_step :integra, :after => :payment
  
   # insert_checkout_step :webpay, :after => :payment, if: Proc.new {|order| order.has_webpay_payment_method? or order.state == Spree::Gateway::WebpayPlus.STATE}
   # remove_transition from: :payment, to: :complete,  if: Proc.new {|order| order.has_webpay_payment_method? or order.state == Spree::Gateway::WebpayPlus.STATE}
  end
end