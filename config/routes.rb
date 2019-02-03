Rails.application.routes.draw do
  get 'index' => 'eco_indicator#index'
  post 'show' => 'eco_indicator#show'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
