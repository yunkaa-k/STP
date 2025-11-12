# frozen_string_literal: true

RSpec.describe RubyOutboxGem::OutboxEvent do
  # Очищуємо таблицю перед кожним тестом
  before { RubyOutboxGem::OutboxEvent.delete_all }

  it "може бути створений з валідними атрибутами" do
    event = RubyOutboxGem::OutboxEvent.create(
      event_type: "UserCreated",
      payload: { user_id: 123 },
      status: :pending,
      send_at: Time.current
    )

    expect(event).to be_persisted
    expect(event.event_type).to eq("UserCreated")
    # Зверніть увагу: JSON серіалізація перетворює ключі на рядки
    expect(event.payload).to eq({ "user_id" => 123 })
    expect(event).to be_pending
  end

  it "правильно використовує скоуп 'ready_to_process'" do
    # 1. Ця подія готова до обробки
    RubyOutboxGem::OutboxEvent.create!(
      event_type: "EventReady", status: :pending, send_at: 1.minute.ago
    )

    # 2. Ця подія запланована на майбутнє
    RubyOutboxGem::OutboxEvent.create!(
      event_type: "EventFuture", status: :pending, send_at: 1.hour.from_now
    )

    # 3. Ця подія вже оброблена
    RubyOutboxGem::OutboxEvent.create!(
      event_type: "EventSent", status: :sent, send_at: 1.minute.ago
    )

    ready_events = RubyOutboxGem::OutboxEvent.ready_to_process
    
    expect(ready_events.count).to eq(1)
    expect(ready_events.first.event_type).to eq("EventReady")
  end
end