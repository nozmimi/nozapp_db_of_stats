Rails.application.routes.draw do
  get 'index' => 'eco_indicator#index'
  get 'show' => 'eco_indicator#show'
  get '' => 'eco_indicator#test'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
