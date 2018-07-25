class SessionsController < ApplicationController
  def callback
    auth                         = request.env['omniauth.auth']
    session[:oauth_token]        = auth.credentials.token

    redirect_to endpoints_after_authorization_path
  end

  def failure
    redirect_to session[:prev_uri]
  end
end
