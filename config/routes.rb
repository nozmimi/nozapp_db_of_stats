Rails.application.routes.draw do
  get 'index' => 'eco_indicator#index'
  get 'nea_data' => 'eco_indicator#nea_data'
  get 'admini_controller' => 'eco_indicator#admini_controller'
  post 'admini_controller' => 'eco_indicator#update_data'
end
