Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'embed' => 'embed#get'

  get 'iframe' => 'embed#iframe'

  get 'iiif' => 'embed#iiif'

  if Rails.env.production?
    root to: proc { [200, {}, ['OK'] ] }
  else
    root to: 'pages#home'
    get '/pages/*id' => 'pages#show', as: :page, format: false
  end

  if Rails.env.test?
    require_relative Rails.root.join('spec/support/stub_apps/stub_auth_endpoint')
    require_relative Rails.root.join('spec/support/stub_apps/stub_auth_jsonp_endpoint')

    mount StubAuthEndpoint.new, at: '/test_auth_endpoint'
    mount StubAuthJsonpEndpoint.new, at: '/test_auth_jsonp_endpoint'
  end
end
