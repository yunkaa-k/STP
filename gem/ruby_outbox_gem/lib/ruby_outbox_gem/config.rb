# lib/ruby_outbox_gem/config.rb

module RubyOutboxGem
  class Config
    attr_accessor :max_retries, :poll_interval, :publisher_middleware
    attr_accessor :handlers

    def initialize
      @max_retries = 5                # Максимальна кількість спроб відправки
      @poll_interval = 5              # Інтервал опитування таблиці диспатчером (у секундах)
      @publisher_middleware = []      # Можливість додати проміжний код перед відправкою
      @handlers = {}                  # Список обробників подій
    end
  end
end