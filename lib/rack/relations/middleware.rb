module Rack
  module Relations
    class Middleware
      attr_accessor :app, :processor

      def initialize(app, safelist_domains: [])
        @app = app
        @processor = Rack::Relations::Processor.new(safelist_domains: safelist_domains)
      end

      def call(env)
        status, headers, response = @app.call(env)

        response = @processor.perform(response)

        [status, headers, response]
      end
    end
  end
end
