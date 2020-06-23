require "test_helper"

describe Rack::Relations do
  describe "::VERSION" do
    it "has a version number" do
      refute_nil ::Rack::Relations::VERSION
    end
  end
end
