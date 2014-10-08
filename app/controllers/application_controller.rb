class ApplicationController < ActionController::Base
  protect_from_forgery

  include SessionsHelper

  before_filter :redirect_https

  def not_found
    render file: "#{Rails.root}/public/404", layout: false, status: 404
  end

  def redirect_https
    if (!request.ssl? && Rails.env.production?)
      redirect_to protocol: "https://", host: Settings::HOST
    end
    return true
  end

end
