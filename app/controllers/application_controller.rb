class ApplicationController < ActionController::Base
  protect_from_forgery

  include SessionsHelper

  before_filter :redirect_https

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def redirect_https
    if (!request.ssl? && Rails.env.production?)
      redirect_to protocol: "https://", host: ENV['HOST']
    end
    return true
  end

  def transaction
    ActiveRecord::Base.transaction do
      yield
    end
  end
end
