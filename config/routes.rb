Tasks::Application.routes.draw do
  devise_for :users

  resources :projects do
    resources :tasks
  end

  match '/projects/:id/sort_tasks' => 'projects#show', :as => 'sort_tasks', :defaults => {:sort_tasks => true}
  match '/toggle_task_completed/:id' => 'tasks#toggle_completed', :as => 'toggle_task_completed', :via => :put
  
  root :to => "projects#index"
end
