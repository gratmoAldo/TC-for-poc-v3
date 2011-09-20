ActionController::Routing::Routes.draw do |map|
  map.resources :subscriptions
  map.resources :myinbox

  # Service Center
  map.resources :inbox_srs
  map.resources :inboxes
  map.resources :site_messages
  map.resources :notes
  map.resources :escalations
  map.resources :sites
  map.resources :service_requests do |service_requests|
    service_requests.resources :notes
  end
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end
  
  # Content Hub
  map.resources :top_tags
  map.resources :bookmarks
  map.resources :links
  map.resources :translations
  map.resources :taggings
  map.resources :tags
  map.resources :assets, :member => { :recover => :put }
  map.expire 'documentation/expire_cache', :controller => 'documentations', :action => 'expire_cache'
  map.documentation 'documentation/:pname.:format', :controller => 'documentations', :action => 'show'

  # User Management
  map.resources :users
  map.signup 'signup', :controller => 'users', :action => 'new'
  map.logout 'logout', :controller => 'sessions', :action => 'destroy'
  map.login 'login', :controller => 'sessions', :action => 'new'
  map.resources :sessions
  map.console 'console', :controller => 'console', :action => 'index'
  map.myinbox 'myinbox', :controller => 'myinbox', :action => 'index'


  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"
  # map.home '', :controller => "assets"
  map.root :controller => "service_requests"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
