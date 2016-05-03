Rails.application.routes.draw do


  resources :grupos
  resources :precios
  resources :formulas
  resources :skus
  resources :sent_orders
  resources :product_orders
  resources :ocs

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

 
  get 'inventario/run'

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
  
  root 'home#index'
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
