Stripe.api_key = Settings::STRIPE_API_SECRET_KEY

require 'erb'

class ApiController < ApplicationController
  before_action :authorize
  before_action :needs_moderator, only: [:hide_from_recent]
  skip_before_action :authorize, only: [:create_stripe_checkout]

  def create_stripe_checkout
      session = Stripe::Checkout::Session.create({
        payment_method_types: ['card'],
        line_items: [{
          price_data: {
            currency: 'usd',
            product_data: {
              name: 'SciRate Job Ad',
            },
            unit_amount: Settings::SCIRATE_JOB_AD_PRICE_USD,
          },
          quantity: 1,
        }],
        mode: 'payment',
        success_url: Settings::STRIPE_SUCCESS_URL + "?jobId=" + params[:jobId],
        cancel_url: Settings::STRIPE_CANCEL_URL,
        payment_intent_data: {
          metadata: { "jobId": params[:jobId] , "contactEmail": params[:e] }
        }
      })

      render json: { id: session.id }
  end

  def scite
    @paper = Paper.find_by_uid!(params[:paper_uid])
    current_user.scite!(@paper)

    if request.xhr?
      render json: true
    else
      redirect_to @paper
    end
  end

  def unscite
    @paper = Paper.find_by_uid!(params[:paper_uid])
    current_user.unscite!(@paper)

    if request.xhr?
      render json: true
    else
      redirect_to @paper
    end
  end

  def subscribe
    @feed = Feed.find_by_uid!(params[:feed_uid])
    current_user.subscribe!(@feed)
    if request.xhr?
      render json: true
    else
      redirect_to @feed
    end
  end

  def unsubscribe
    @feed = Feed.find_by_uid!(params[:feed_uid])
    current_user.unsubscribe!(@feed)
    if request.xhr?
      render json: true
    else
      redirect_to @feed
    end
  end

  def resend_confirm
    current_user.send_signup_confirmation
    render json: { success: true }
  end

  # Retrieve or update misc. user account settings
  def settings
    settings = [:expand_abstracts]

    if request.post?
      current_user.update!(params.permit(*settings))
    end

    render json: current_user.slice(*settings)
  end

  def hide_from_recent
    comment = Comment.find_by_id!(params[:comment_id])

    comment.hidden_from_recent = true
    comment.save!

    render json: { success: true }
  end

  private
    def authorize
      unless signed_in?
        session[:return_to] = request.fullpath
        render json: { error: 'login_required' }, status: 401
      end
    end

    def needs_moderator
      unless signed_in? && current_user.can_moderate?
        render json: { error: 'unauthorized' }, status: 403
      end
    end
end
