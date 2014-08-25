class ApplicationController < ActionController::Base
  protect_from_forgery

  include SessionsHelper

  before_filter :redirect_https

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def redirect_https
    if (!request.ssl? && Rails.env.production?)
      redirect_to protocol: "https://", host: Settings::HOST
    end
    return true
  end

  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
      request.user_agent =~ /Mobile|webOS/
    end
  end

  helper_method :mobile_device?
end
