#!/usr/bin/env ruby

puts "--- [Manual Test] Starting ---"

# 1. Завантажуємо всі геми
require "bundler/setup"

# 2. Налаштовуємо нашу тестову базу даних (!!!)
# Ми "крадемо" наш RSpec-хелпер, щоб створити БД в пам'яті та запустити міграції
puts "[Test] Setting up in-memory database and running migrations..."
require_relative "spec/support/database"

# 3. Завантажуємо наш гем
require_relative "lib/ruby_outbox_gem"

puts "[Test] Database is ready."

# 4. Налаштовуємо гем: створюємо обробник, який просто друкує в консоль
puts "[Test] Configuring handler for 'TestEvent'..."
RubyOutboxGem.configure do |config|
  # Встановлюємо короткий інтервал для тесту
  config.poll_interval = 2 

  config.handlers["TestEvent"] = ->(payload) {
    puts "=============================================="
    puts "✅ HANDLER EXECUTED! Payload: #{payload.inspect}"
    puts "=============================================="
  }
end

# 5. Публікуємо тестову подію
puts "[Test] Publishing 'TestEvent'..."
RubyOutboxGem::Publisher.publish("TestEvent", { user_id: 123, time: Time.now })

# Перевіряємо, що вона в БД
event_count = RubyOutboxGem::OutboxEvent.pending.count
puts "[Test] Event saved to DB. Pending events: #{event_count}"

# 6. Запускаємо воркер (копіюємо логіку з bin/ruby_outbox_worker)
puts "\n--- Starting Worker (Press Ctrl+C to stop) ---"

begin
  # Ми запустимо лише кілька циклів для тесту
  5.times do
    puts "[Worker] Polling for jobs..."
    RubyOutboxGem::Dispatcher.new.call
    
    # Перевіряємо, чи подія була оброблена
    if RubyOutboxGem::OutboxEvent.sent.count > 0
      puts "[Worker] Job processed! Exiting."
      break
    end

    sleep RubyOutboxGem.config.poll_interval
  end
rescue Interrupt
  puts "\n[Worker] Stopped."
end

puts "\n--- [Manual Test] Finished ---"