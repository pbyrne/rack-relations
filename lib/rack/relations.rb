require "rack"
require "rack/relations/version"

require "rack/relations/anchor"
require "rack/relations/middleware"
require "rack/relations/processor"

module Rack
  module Relations
    Error = Class.new(StandardError)
  end
end
