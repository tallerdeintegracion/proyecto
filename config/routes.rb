Rails.application.routes.draw do

  resources :saldos
  resources :social_media
  resources :boleta
  resources :boleta
  resources :boleta
  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Spree relies on it being the default of "spree"
  mount Spree::Core::Engine, at: '/spree'

  patch '/integracionpay', :to =>  "integracionpay#pay", :as => :integracionpay
  get '/integracionpay/confirm/:id' => "integracionpay#confirm"
  get '/integracionpay/cancel/:id' => "integracionpay#cancel"

  resources :ocs
  resources :skus
  resources :sent_orders
  resources :grupos
  resources :precios
  resources :formulas
  resources :product_orders

scope '/api' do
    scope '/consultar' do
      scope '/:sku' do
        get '/' => 'api#inventarioConsultar'
      end
    end
    scope '/facturas' do
      scope '/recibir' do
        scope '/:id' do
          get '/' => 'api#facturarRecibir'
        end
      end
    end
    scope '/oc' do
      scope '/recibir' do
        scope '/:id' do
          get '/' => 'api#ocRecibir'
        end
      end
    end
    scope '/pagos' do
      scope '/recibir' do
        scope '/:id' do
          get '/' => 'api#pagoRecibir'
        end
      end
    end
    scope '/despachos' do
      scope '/recibir' do
        scope '/:id' do
          get '/' => 'api#despachoRecibir'
        end
      end
    end
end   

#  post 'api/facturas/recibir/:id' => 'api#facturarRecibir'
#  post 'api/pagos/recibir/:id' => 'api#pagosRecibir'
#  post 'api/oc/recibir/:id' => 'api#ocRecibir'

  get 'socialmedia/search'
  get 'inventario/run'
  get 'home/bodegas'
  get 'home/test'
  get 'receive_orders/receive'
  get 'home/documentacion'
  get 'skus/index'
  get 'skus/new'
  get 'skus/show'
  get 'skus/edit'
  get 'skus/destroy'
  get 'formulas/index'
  get 'formulas/new'
  get 'formulas/show'
  get 'formulas/edit'
  get 'formulas/destroy'
  get 'precios/index'
  get 'precios/new'
  get 'precios/show'
  get 'precios/edit'
  get 'precios/destroy'
  get 'ocs/index'
  get 'ocs/new'
  get 'ocs/show'
  get 'ocs/edit'
  get 'ocs/destroy'  
  get 'sent_orders/index'
  get 'sent_orders/new'
  get 'sent_orders/show'
  get 'sent_orders/edit'
  get 'sent_orders/destroy'
  get 'api/documentacion' => 'home#documentacion'
  get 'api/documentacion'
  get 'home/bodegas'
  
  get 'inventario/vaciar'
  get 'inventario/mover' => 'inventario#moverMiStock'
  get 'saldos/show'
  get 'home/index'
  
  get 'home/listaOrdenesCompra'
  get 'home/productos'
  get 'home/credenciales'

  root 'home#index'

  get 'home/test'

  get 'home/dashboard'
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
