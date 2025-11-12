# frozen_string_literal: true

require "active_record"

# 1. Встановлюємо з'єднання
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

# 2. Знаходимо шлях до папки з міграціями
#    (__dir__ це /spec/support, тому піднімаємось на 2 рівні)
migration_directory = File.expand_path("../../db/migrate", __dir__)

# 3. Створюємо "Контекст міграції" - це офіційний спосіб
#    сказати ActiveRecord, де шукати міграції.
migration_context = ActiveRecord::MigrationContext.new(migration_directory)

# 4. Запускаємо міграції.
#    Це надійно запустить всі файли в папці db/migrate
#    на базі даних, до якої ми підключилися вище.
puts "[RSpec] Running migrations via MigrationContext..."
migration_context.migrate
puts "[RSpec] Migrations complete."