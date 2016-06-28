
# Configure Spree Preferences
#
# Note: Initializing preferences available within the Admin will overwrite any changes that were made through the user interface when you restart.
#       If you would like users to be able to update a setting with the Admin it should NOT be set here.
#
# Note: If a preference is set here it will be stored within the cache & database upon initialization.
#       Just removing an entry from this initializer will not make the preference value go away.
#       Instead you must either set a new value or remove entry, clear cache, and remove database entry.
#
# In order to initialize a setting do:
# config.setting_name = 'new value'
Spree.config do |config|
  # Example:
  # Uncomment to stop tracking inventory levels in the application
  # config.track_inventory_levels = false
end

Spree::Auth::Config[:confirmable] = true

Spree.user_class = "Spree::User"

Rails.application.config.spree.payment_methods << Spree::Gateway::Integracionpay
#Rails.application.config.spree.promotions.actions << DescuentoProducto
=begin
class Descprod < Spree::PromotionAction
  has_many :promotion_action_line_items, foreign_key: :promotion_action_id


  def perform(options={})
    Rails.logger.debug( "precioNuevo: "+precioNuevo.to_s )
    Rails.logger.debug( "idProducto: "+idProducto.to_s )
    Rails.logger.debug( "objeto: "+promotion.to_s )

    #(object.amount * preferred_percent) / 100
  end
end

config = Rails.application.config
config.assets.debug = false
config.after_initialize do

  Rails.application.config.spree.promotions.actions << Descprod
end  
=end
config = Rails.application.config

config.after_initialize do
  Rails.application.config.spree.promotions.actions << Spree::Promotion::Actions::DescuentoProducto
  Rails.application.config.spree.calculators.promotion_actions_create_adjustments << 
    Spree::Calculator::ProductWithOptionValueCalculator
=begin
  Rails.application.config.spree.calculators.promotion_actions_create_adjustments << 
    Spree::Calculator::ProductWithOptionValueCalculator
  #Rails.application.config.spree.promotions.actions <<
    Spree::Promotion::Actions::ProductWithOptionValueAction
  Rails.application.config.spree.promotions.rules << 
    Spree::Promotion::Rules::ProductWithOptionValueRule
=end
end
#initializer "spree.promo.register.promotions.rules" do |app|
#end
#    app.config.spree.promotions.calculator += [Spree::Promotion::Calculator::DescuentoProducto]