require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  root 'root#dashboard'

  get '/about', to: 'root#about'
  get '/inquiries', to: 'root#inquiry'
  post '/inquiries', to: 'root#send_inquiry'
  get '/terms', to: 'root#terms'

  get '/endpoint', to: 'endpoint#index', as: :endpoint_index
  get '/endpoint/statistics', to: 'endpoint#statistics', as: :endpoint_statistics
  get '/endpoint/:id', to: 'endpoint#show', as: :endpoint
  get '/endpoint/:id/scores', to: 'endpoint#scores', as: :endpoint_scores
  get '/endpoint/:id/histories', to: 'endpoint#histories', as: :endpoint_histories
  get '/endpoint/:id/log/:name', to: 'endpoint#log', as: :endpoint_log

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  if ENV['SIDEKIQ_USER'].present? && ENV['SIDEKIQ_PASSWORD'].present?
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_USER'])) &
        ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_PASSWORD']))
    end
  end

  mount Sidekiq::Web, at: '/sidekiq'
end
