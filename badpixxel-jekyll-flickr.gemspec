# frozen_string_literal: true

require_relative "lib/badpixxel-jekyll-flickr/version"

Gem::Specification.new do |spec|
  spec.name          = "badpixxel-jekyll-flickr"
  spec.version       = Jekyll::FLICKR_VERSION
  spec.authors       = ["BadPixxel"]
  spec.email         = ["eshop.bpaquier@gmail.com"]
  spec.summary       = "A Jekyll plugin to embed Flickr Sets & Photos in your Jekyll blog"
  spec.homepage      = "https://github.com/BadPixxel/jekyll-flickr"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.3.0"

  spec.add_dependency "jekyll", ">= 3.7", "< 5.0"
  spec.add_dependency "flickraw"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "nokogiri", "~> 1.6"
  spec.add_development_dependency "rspec", "~> 3.0"
end