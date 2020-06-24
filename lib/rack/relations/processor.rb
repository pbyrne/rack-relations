require "nokogiri"

module Rack
  module Relations
    class Processor
      # TODO rename safelist_domains, might have other safelists?
      attr_accessor :safelist_domains

      def initialize(safelist_domains:)
        @safelist_domains = safelist_domains
      end

      def perform(body)
        doc = parsed_body(body.join("\n"))

        doc.css("a[href]").each do |node|
          anchor = Anchor.new(node, safelist_domains: safelist_domains)
          next if anchor.safe?

          node.set_attribute("rel", anchor.modified_rel)
        end

        [doc.to_html]
      end

      private def parsed_body(text)
        if text =~ /<!DOCTYPE/i
          Nokogiri::HTML(text)
        else
          Nokogiri::HTML.fragment(text)
        end
      end
    end
  end
end
