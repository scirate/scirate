require 'jwt'
require 'net/http'
require 'json'

module ApplicationHelper
  def status_warning
    raw "<span class=\"warning\">#{current_user.account_status}:</span>"
  end

  def timeago(dt)
    dt = Time.parse(dt) if dt.is_a? String
    raw "<abbr class=\"timeago\" title=\"#{dt.iso8601}\">#{dt.strftime("%b %d %Y %R UTC")}</abbr>"
  end

  def user_link(user)
    raw "<a href='/#{h(user.username)}'>#{h(user.fullname)}</a>"
  end

  def mk_jwt_token(role, job_token)
    exp = Time.now.to_i + (Settings::JWT_EXPIRY_MINUTES * 60)
    payload = { 'admin': false,
                'exp': exp,
                'https://hasura.io/jwt/claims':
                  { 'x-hasura-allowed-roles': [role],
                    'x-hasura-default-role': role,
                    'x-hasura-job-token': job_token || "",
                    'x-hasura-job-date-modified': Time.now
                  }
              }

    alg    = Settings::GRAPHQL_JWT_ALGORITHM
    key    = Settings::GRAPHQL_JWT_SECRET

    JWT.encode payload, key, alg
  end

  def run_graphql_query(query)
    token = mk_jwt_token('ruby', '')
    uri   = URI(Settings::GRAPHQL_URL)
    http  = Net::HTTP.new(uri.host, uri.port)
    req   = Net::HTTP::Post.new(uri.path,
                                {'Content-Type' => 'application/json',
                                'Authorization' => "Bearer #{token}"})

    req.body = {'query': query}.to_json

    res = http.request(req)
    JSON.parse(res.body)
  rescue => e
    logger.error("Error with GraphQL: #{e}")
    {}
  end
end
