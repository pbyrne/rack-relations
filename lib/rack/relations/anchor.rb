require "uri"

module Rack
  module Relations
    class Anchor
      attr_accessor :node, :safelist_domains, :uri

      def initialize(node, safelist_domains:)
        @node = node
        @safelist_domains = safelist_domains
        @uri = URI(node.attr("href")) rescue nil
      end

      def modified_rel
        "#{node.attr("rel")} nofollow noopener noreferrer".strip
      end

      def safe?
        return true if uri.relative?

        safelist_domains.any? { |matcher| match?(matcher: matcher, host: uri.host) }
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
