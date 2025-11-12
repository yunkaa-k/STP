# frozen_string_literal: true

module RubyOutboxGem
  class Dispatcher
    # Скільки подій брати з БД за один запит
    BATCH_SIZE = 100

    def call
      # Ми обробляємо події у нескінченному циклі (або доки не виникне помилка)
      # У реальному воркері тут буде `loop do ... end`
      process_batch
    end

    private

    # 1. Знайти та заблокувати пакет подій
    def process_batch
      events = find_and_lock_batch
      
      # Обробляємо кожну подію окремо
      events.each do |event|
        process_event(event)
      end
    end

    def find_and_lock_batch
      # Це найважливіша частина.
      # Ми використовуємо транзакцію та блокування `SKIP LOCKED`,
      # щоб кілька воркерів могли працювати паралельно, не беручи
      # одну й ту саму подію.
      OutboxEvent.transaction do
        OutboxEvent
          .ready_to_process # Використовуємо наш скоуп (pending + send_at <= now)
          .order(send_at: :asc)
          .limit(BATCH_SIZE)
          .lock("FOR UPDATE SKIP LOCKED") # PostgreSQL / MySQL синтаксис
          .to_a # Виконуємо запит всередині транзакції
      end
    end

    # 2. Обробка однієї події
    def process_event(event)
      # Знаходимо обробник, який користувач налаштував для цього типу події
      handler = RubyOutboxGem.config.handlers[event.event_type]

      unless handler
        # Якщо обробник не знайдено, це критична помилка
        event.mark_as_failed!(error_message: "No handler registered for #{event.event_type}")
        return
      end

      # 3. Виклик обробника
      begin
        # Позначаємо, що ми почали обробку
        event.update!(status: :processing, last_attempt_at: Time.current)
        
        # Викликаємо код користувача (наприклад, відправка в Kafka)
        handler.call(event.payload)
        
        # Якщо помилки не було, позначаємо як відправлену
        handle_success(event)
      rescue StandardError => e
        # Якщо код користувача (handler.call) видав помилку
        handle_failure(event, e)
      end
    end

    # 4. Обробка успіху
    def handle_success(event)
      event.mark_as_sent!
    end

    # 5. Обробка помилки та логіка ретраїв
    def handle_failure(event, error)
      config = RubyOutboxGem.config
      
      if event.retries_count < config.max_retries
        # Повторна спроба
        next_send_at = calculate_backoff(event.retries_count)
        event.increment_retries!(next_send_at)
      else
        # Досягнуто ліміту ретраїв, позначаємо як 'failed'
        event.mark_as_failed!(error_message: error.message)
      end
    end

    # 6. Розрахунок експоненційної затримки (Exponential Backoff)
    def calculate_backoff(retries_count)
      # 2^N секунд (наприклад, 2, 4, 8, 16, 32...)
      delay_seconds = 2**retries_count
      Time.current + delay_seconds.seconds
    end
  end
end