require "uri"

module Rack
  module Relations
    class Anchor
      attr_accessor :node, :safelist, :uri

      def initialize(node, safelist:)
        @node = node
        @safelist = safelist
        @uri = URI(node.attr("href")) rescue nil
      end

      def modified_rel
        "#{node.attr("rel")} nofollow noopener noreferrer".strip
      end

      def safe?
        return true if uri.relative?
        return true if safelist.any? { |matcher| match?(matcher: matcher, host: uri.host) }

        false
      end

      private def match?(matcher:, host:)
        case matcher
        when String
          host.end_with?(matcher)
        when Regexp
          host =~ matcher
        end
      end
    end
  end
end
