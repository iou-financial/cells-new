require_relative 'lib/cell_new/version'

Gem::Specification.new do |spec|
  spec.name        = 'cells-new'
  spec.version     = CellNew::VERSION
  spec.authors     = ['Nick Sutterer']
  spec.email       = ['apotonick@gmail.com']
  spec.homepage    = 'https://github.com/iou-fnancial/cells-new'
  spec.summary     = 'View Models for Ruby and Rails.'
  spec.description = 'View Models for Ruby and Rails, replacing helpers and partials while giving you a clean view architecture with proper encapsulation. This is a fork to rename the gem from cell_news to cell_news-new so that we can use this gem and apotomo which requires and older version used in tandem.'
  spec.license     = 'MIT'

  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/HEAD/CHANGES.md"
  spec.metadata['documentation_uri'] = 'https://trailblazer.to/2.1/docs/cells'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['wiki_uri'] = "#{spec.homepage}/wiki"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |file|
      file.start_with?(*%w[.git Gemfile Rakefile TODO test])
    end
  end
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.5'

  spec.add_dependency 'declarative-builder', '~> 0.2.0'
  spec.add_dependency "trailblazer-option", "~> 0.1.0"
  spec.add_dependency 'tilt', '>= 1.4', '< 3'
  spec.add_dependency 'uber', '< 0.2.0'

  spec.add_development_dependency 'capybara'
  spec.add_development_dependency 'cells-erb', '>= 0.1.0'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'debug'
end
