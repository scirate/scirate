# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

class Garbage
  def initialize(app)
    @app = app
  end

  def call(env)
    GC.disable
    v = @app.call(env)
    GC.enable
    v
  end
end

use Garbage

if Rails.env.profile?
  use StackProf::Middleware, enabled: true,
                             mode: :cpu,
                             interval: 1000,
                             save_every: 5
end

run SciRate::Application
