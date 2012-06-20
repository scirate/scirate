class ApplicationController < ActionController::Base
  protect_from_forgery

  include SessionsHelper

  before_filter :redirect_https

  def redirect_https
    if (!request.ssl? && Rails.env.production?)
      redirect_to protocol: "https://", host: ENV['HOST']
    end
    return true
  end
end
