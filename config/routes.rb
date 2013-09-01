MedicaidEligibilityApi::Application.routes.draw do
  resources :determinations, only: [] do
    post 'eval', :on => :collection
  end

  resources :rulesets, defaults: {format: 'json'}, constraints: { :id => /.+?/ } do
    post 'eval', :on => :member
  end
end
