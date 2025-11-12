# frozen_string_literal: true

module RubyOutboxGem
  # Модуль-інтерфейс для публікації подій.
  # Це приховує логіку створення OutboxEvent від користувача.
  module Publisher
    # Головний метод для публікації події.
    #
    # @param event_type [String] Назва події (наприклад, 'UserCreated')
    # @param payload [Hash] Дані події (наприклад, { user_id: 1 })
    #
    def self.publish(event_type, payload)
      # Ми просто створюємо запис у базі даних.
      # Диспатчер підхопить його пізніше.
      OutboxEvent.create!(
        event_type: event_type,
        payload: payload,
        status: :pending,
        send_at: Time.current # Готово до відправки негайно
      )
    end
  end
end