# frozen_string_literal: true

require "active_record"
require "json"

module RubyOutboxGem
  # Модель для представлення події, що очікує на відправку.
  class OutboxEvent < ActiveRecord::Base
    # Явно вказуємо назву таблиці
    self.table_name = "outbox_events"

    # Використовуємо enum для статусів (зберігаються як 0, 1, 2, 3)
    # Це ефективніше для індексації.
    enum :status, {
      pending: 0,
      processing: 1,
      sent: 2,
      failed: 3
    }

    # Автоматично перетворюємо Ruby Hash в JSON при збереженні
    # і назад при читанні з поля payload.
    serialize :payload, coder: JSON

    # --- Скоупи (Scopes) для Диспатчера ---

    # Знайти всі події, які готові до обробки
    # (статус 'pending' і час відправки вже настав)
    scope :ready_to_process, -> {
      pending.where("send_at <= ?", Time.current)
    }

    # --- Методи життєвого циклу ---

    def mark_as_sent!
      update!(status: :sent, last_attempt_at: Time.current)
    end

    def mark_as_failed!(error_message: nil)
      update!(status: :failed, last_attempt_at: Time.current)
      # TODO: Додати поле error_details для запису error_message
    end

    def increment_retries!(next_send_at)
      self.retries_count += 1
      self.send_at = next_send_at
      self.status = :pending # Повертаємо в 'pending' для повторної спроби
      self.last_attempt_at = Time.current
      save!
    end
  end
end