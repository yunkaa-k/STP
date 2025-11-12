# frozen_string_literal: true

require "active_record/migration"

# Це міграція, яку користувачі гему мають запустити у своєму додатку.
class CreateOutboxEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :outbox_events do |t|
      t.string :event_type, null: false
      
      # JSONB для PostgreSQL, TEXT (з serialize) для MySQL/SQLite
      # Використаємо :text, оскільки він універсальний, 
      # а наша модель подбає про JSON-серіалізацію.
      t.text :payload

      # Статус у вигляді integer (для enum)
      t.integer :status, default: 0, null: false
      
      t.integer :retries_count, default: 0, null: false
      t.datetime :send_at, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :last_attempt_at

      t.timestamps
    end

    # !!! Дуже важливий індекс для диспатчера !!!
    # Він дозволяє швидко знаходити події зі статусом 'pending' (0)
    # і сортувати їх за часом відправки.
    add_index :outbox_events, [:status, :send_at], name: "idx_outbox_on_status_and_send_at"
  end
end