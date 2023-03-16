require_relative 'lib/rack/relations/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-relations"
  spec.version       = Rack::Relations::VERSION
  spec.authors       = ["Patrick Byrne"]
  spec.email         = ["code@patrickbyrne.net"]

  spec.summary       = %q{Dynamically rewrite markup to add `rel="nofollow noopener noreferrer"` to non-safelisted links.}
  spec.homepage      = "https://github.com/pbyrne/rack-relations.git"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/pbyrne/rack-relations.git"
  spec.metadata["changelog_uri"] = "https://github.com/pbyrne/rack-relations.git/blob/master/CHANGELOG.markdown"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "nokogiri", "~> 1.10"
  spec.add_runtime_dependency "rack", ">= 2.0", "< 4"

  spec.add_development_dependency "mocha"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rack-test"
end
