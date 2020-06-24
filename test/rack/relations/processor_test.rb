require "test_helper"

describe Rack::Relations::Processor do
  describe "#perform" do
    subject { Rack::Relations::Processor.new(safelist: []) }

    it "gracefully handles invalid markup" do
      body = ["not markup"]

      result = subject.perform(body)

      assert_equal body, result
    end

    it "applies `rel` attribute to links in an HTML fragment" do
      body = [%{<p><a href="https://example.com">foo</a> bar</p>}]

      result = subject.perform(body)

      assert_equal [%{<p><a href="https://example.com" rel="nofollow noopener noreferrer">foo</a> bar</p>}],
        result
    end

    it "applies `rel` attribute to links in a complete HTML document" do
      body = [
        <<~EOH
        <!DOCTYPE html>
        <html>
        <head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"> <title>title</title>
        </head>
        <body>
        <h1>heading!</h1>
        <p><a href="https://example.com">foo</a><a></a></p>
        </body>
        </html>
        EOH
      ]

      result = subject.perform(body)

      assert_equal [
        <<~EOH
        <!DOCTYPE html>
        <html>
        <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"> <title>title</title>
        </head>
        <body>
        <h1>heading!</h1>
        <p><a href="https://example.com" rel="nofollow noopener noreferrer">foo</a><a></a></p>
        </body>
        </html>
        EOH
      ], result
    end

    it "does not destroy existing `rel` attribute values" do
      body = [%{<a href="https://example.com" rel="canonical">bar</a>}]

      result = subject.perform(body)

      assert_equal [%{<a href="https://example.com" rel="canonical nofollow noopener noreferrer">bar</a>}],
        result
    end

    it "does not add `rel` attribute to local links" do
      body = [%{<a href="/foo">bar</a>}]

      result = subject.perform(body)

      assert_equal body, result
    end

    it "does not remove `rel` attribute from unmodified links" do
      body = [%{<a href="/foo" rel="canonical">foo</a>}]

      result = subject.perform(body)

      assert_equal body, result
    end

    it "does not add `rel` attribute to links with no href" do
      body = [%{<a name="foo">bar</a>}]

      result = subject.perform(body)

      assert_equal body, result
    end

    it "does not add `rel` attribute to links with invalid href" do
      body = [%{<a href="#">foo</a>}]

      result = subject.perform(body)

      assert_equal body, result
    end

    it "does not add `rel` attributes to exact domain safelist matches and their subdomains" do
      body = [
        <<~EOH
        <a href="https://example.com">safe</a>
        <a href="https://foo.example.com">still safe</a>
        <a href="https://foo.example.org">unsafe</a>
        EOH
      ]
      subject = Rack::Relations::Processor.new(safelist: ["example.com"])

      result = subject.perform(body)

      assert_equal [
        <<~EOH
        <a href="https://example.com">safe</a>
        <a href="https://foo.example.com">still safe</a>
        <a href="https://foo.example.org" rel="nofollow noopener noreferrer">unsafe</a>
        EOH
      ], result
    end

    it "does add `rel` attrbiutes to sibling or higher domains" do
      body = [
        <<~EOH
        <a href="https://example.com">unsafe</a>
        <a href="https://foo.example.com">safe</a>
        <a href="https://qux.foo.example.com">also safe</a>
        <a href="https://bar.example.com">unsafe</a>
        EOH
      ]
      subject = Rack::Relations::Processor.new(safelist: ["foo.example.com"])

      result = subject.perform(body)

      assert_equal [
        <<~EOH
        <a href="https://example.com" rel="nofollow noopener noreferrer">unsafe</a>
        <a href="https://foo.example.com">safe</a>
        <a href="https://qux.foo.example.com">also safe</a>
        <a href="https://bar.example.com" rel="nofollow noopener noreferrer">unsafe</a>
        EOH
      ], result
    end

    it "does add `rel` attributes for substring matches that aren't actually subdomains" do
      body = [
        <<~EOH
        <a href="https://example.com">safe</a>
        <a href="https://example.com.haxxor.net">unsafe</a>
        EOH
      ]
      subject = Rack::Relations::Processor.new(safelist: ["example.com"])

      result = subject.perform(body)

      assert_equal [
        <<~EOH
        <a href="https://example.com">safe</a>
        <a href="https://example.com.haxxor.net" rel="nofollow noopener noreferrer">unsafe</a>
        EOH
      ], result
    end

    it "does not add `rel` attributes to domains matching regular expressions in the safelist" do
      body = [
        <<~EOH
        <a href="https://example.org">safe</a>
        <a href="https://foo.example.org">still safe</a>
        <a href="https://example.com">unsafe</a>
        EOH
      ]
      subject = Rack::Relations::Processor.new(safelist: [/\.org$/])

      result = subject.perform(body)

      assert_equal [
        <<~EOH
        <a href="https://example.org">safe</a>
        <a href="https://foo.example.org">still safe</a>
        <a href="https://example.com" rel="nofollow noopener noreferrer">unsafe</a>
        EOH
      ], result
    end
  end
end
