Rails.application.routes.draw do
  get '/' => 'eco_indicator#index'
  get '/database' => 'eco_indicator#database'
  get '/statistics_data' => 'eco_indicator#statistics'
  get '/admini_controller' => 'eco_indicator#admini_controller'
  post '/admini_controller' => 'eco_indicator#update_data'

end
