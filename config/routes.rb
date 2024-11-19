Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'embed' => 'embed#get'
  post 'embed' => 'embed#post'

  get 'iframe' => 'embed#iframe'

  # For viewing external resources with Mirador (e.g. http://embed.stanford.edu/iiif?url=https://dcollections.lib.keio.ac.jp/sites/default/files/iiif/ICP/132X-26-1/manifest.json)
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
    require_relative Rails.root.join('spec/support/stub_apps/stub_metrics_api')

    mount StubAuthEndpoint.new, at: '/test_auth_endpoint'
    mount StubAuthJsonpEndpoint.new, at: '/test_auth_jsonp_endpoint'
    mount StubMetricsApi.new, at: '/test_metrics_api'
  end
end
