$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "minitest/autorun"
require "mocha/minitest"
require "pry"

require "rack/relations"
require "rack/test"

class Minitest::Spec
  include Rack::Test::Methods

  def app
    Rack::Builder.new do
      # Use Rack::Lint to test that rack-relations is complying with the rack spec
      use Rack::Lint
      use Rack::Relations::Middleware
      use Rack::Lint

      run lambda { |_env| [200, {}, ['Hello World']] }
    end.to_app
  end
end
