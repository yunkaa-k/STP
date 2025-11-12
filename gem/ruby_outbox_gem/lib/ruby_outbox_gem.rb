# lib/ruby_outbox_gem.rb

# frozen_string_literal: true

# Залежності, необхідні для роботи гему
require "active_record"
require "json"

# Внутрішні файли гему
require_relative "ruby_outbox_gem/version"
require_relative "ruby_outbox_gem/config"
require_relative "ruby_outbox_gem/models/outbox_event" 
require_relative "ruby_outbox_gem/publisher"
require_relative "ruby_outbox_gem/dispatcher"

module RubyOutboxGem
  class Error < StandardError; end

  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield(config)
  end
end