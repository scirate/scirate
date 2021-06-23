require 'jwt'

class StaticPagesController < ApplicationController
  # Only send a confirmation email if it hasn't been sent yet.
  def job_success
    jobId = params[:jobId]
    query = """
query MyQuery {
  jobs(where: {id: {_eq: #{jobId}}, emailedConfirmation: {_eq: false}}) {
    contactEmail
    contactName
    token
  }
}"""

    resp  = run_graphql_query(query)
    puts "GraphQL Response: "
    puts resp
    jobs = resp["data"]["jobs"]

    if jobs.length == 1
      job = jobs[0]

      # Send the email
      JobMailer.job_notification(job["contactEmail"], job["contactName"], job["token"]).deliver_now

      # Run the 'update' mutation
      q = """
mutation MyMutation {
  update_jobs(
    where: {id: {_eq: #{jobId}}},
    _set: {emailedConfirmation: true}) {
    affected_rows
  }
}
"""
      resp = run_graphql_query(q)
    end
  end

  def submit_job
    @token = mk_jwt_token("editor", params[:i])
  end
end
