Rails.application.routes.draw do
  root "welcome#index"
  devise_for :users
  namespace :api, :defaults => { :format => :json } do
   namespace :v1 do

    get "/me" => "users#show", :as => :user
    patch "/me" => "users#update", :as => :update_user
    
    post "/signup" => "auth#signup"
    post "/login" => "auth#login"
    post "/logout" => "auth#logout"

     get "/reservations" => "reservations#index", :as => :reservations
     get "/trains"  => "trains#index", :as => :trains
     get "/trains/:train_number" => "trains#show", :as => :train

     get "/reservations/:booking_code" => "reservations#show", :as => :reservation
     post "/reservations" => "reservations#create", :as => :create_reservations
     patch "/reservations/:booking_code" => "reservations#update", :as => :update_reservation
     delete "/reservations/:booking_code" => "reservations#destroy", :as => :cancel_reservation
   end
 end
  resources :cities do
    member do
      post :update_temp
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
