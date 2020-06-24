require "test_helper"

describe Rack::Relations::Middleware do
  let(:memoized_app) { app }
  let(:safelist) { ["example.com"] }

  describe "#initialize" do
    it "remembers the information given to it" do
      subject = Rack::Relations::Middleware.new(memoized_app, safelist: safelist)

      assert_equal memoized_app, subject.app
      assert_equal safelist, subject.processor.safelist
    end

    it "defaults to an empty safelist" do
      subject = Rack::Relations::Middleware.new(app)

      assert_equal [], subject.processor.safelist
    end
  end

  describe "#call" do
    let(:rack_env) { "Rack env hash" }
    let(:headers) { "Rack headers hash" }
    let(:original_response) { "Rack response array" }
    let(:processed_response) { "Middleware-processed response" }
    let(:status) { "Rack status code" }

    it "processes the response" do
      subject = Rack::Relations::Middleware.new(memoized_app)
      memoized_app.expects(:call).with(rack_env).returns([status, headers, original_response])
      subject.processor.expects(:perform).with(original_response).returns(processed_response)

      result = subject.call(rack_env)

      assert_equal [status, headers, processed_response], result
    end
  end
end
