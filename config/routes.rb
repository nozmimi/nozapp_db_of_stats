Rails.application.routes.draw do
  get 'index' => 'eco_indicator#index'
  get 'nea_data' => 'eco_indicator#nea_data'
  post '' => 'eco_indicator#update_data'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
