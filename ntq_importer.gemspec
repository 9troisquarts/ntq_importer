# frozen_string_literal: true

require_relative "lib/ntq_importer/version"

Gem::Specification.new do |spec|
  spec.name          = "ntq_importer"
  spec.version       = NtqImporter::VERSION
  spec.authors       = ["Alexandre"]
  spec.email         = ["alexandre@9troisquarts.com"]

  spec.summary       = "9tq importer gem."
  spec.description   = "9tq importer gem."
  spec.homepage      = "https://github.com/9troisquarts/ntq_importer/"
  spec.required_ruby_version = ">= 2.5.0"

  spec.metadata["allowed_push_host"] = "http://kwak.9tq.fr:9292/private"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/9troisquarts/ntq_importerr/"
  spec.metadata["changelog_uri"] = "https://github.com/9troisquarts/ntq_importer/"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", ">= 5.2.6"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency 'factory_bot_rails'
  spec.add_runtime_dependency "interactor-rails"

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
