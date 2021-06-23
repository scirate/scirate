require 'net/https'

class ApplicationController < ActionController::Base
  protect_from_forgery
  RECAPTCHA_MINIMUM_SCORE = 0.5

  include SessionsHelper
  include ApplicationHelper

  before_action :redirect_https
  before_action :set_token

  def set_token
    @token = mk_jwt_token("public", params[:i])
  end

  def not_found
    render file: "#{Rails.root}/public/404", layout: false, status: 404
  end

  def redirect_https
    if (!request.ssl? && Rails.env.production?)
      redirect_to protocol: "https://", host: Settings::HOST
    end
    return true
  end

  def verify_recaptcha?(token, recaptcha_action)
    
    uri = URI('https://www.google.com/recaptcha/api/siteverify')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'})
    req.set_form_data("secret" => Settings::RECAPTCHA_SECRET_KEY, "response" => token)
    res = http.request(req)
    json = JSON.parse(res.body)
    json['success'] && json['score'] > RECAPTCHA_MINIMUM_SCORE && json['action'] == recaptcha_action
  end
end
