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

  def transaction
    ActiveRecord::Base.transaction do
      yield
    end
  end

  def parse_date params
    date = Chronic.parse(params[:date])
    date = date.to_date if !date.nil?

    return date
  end

  def parse_feed params
    feed = Feed.find_by_uid(params[:feed])

    return feed
  end

  def parse_range params
    return nil unless params.has_key?(:range)
    return :since_last if params[:range] == 'since_last'

    range = params[:range].to_i

    # I expect range=2 to show me two days
    range -= 1

    # negative date windows are confusing
    range = 0 if range < 0

    return range
  end
end
