# frozen_string_literal: true

require_relative "lib/ruby_outbox_gem/version"

Gem::Specification.new do |spec|
  spec.name = "ruby_outbox_gem"
  spec.version = RubyOutboxGem::VERSION
  spec.authors = ["yunkaa-k"]
  spec.email = ["elizarliltroll@gmail.com"]

  spec.summary = "col123."
  spec.description = "test123."
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  
  spec.add_dependency "activerecord", "~> 7.0" 
  spec.add_dependency "json"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = ["ruby_outbox_worker"]
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
