# frozen_string_literal: true

RSpec.describe RubyOutboxGem::Publisher do
  # Очищуємо таблицю перед кожним тестом
  before { RubyOutboxGem::OutboxEvent.delete_all }

  let(:event_type) { "OrderConfirmed" }
  let(:payload) { { order_id: 456, amount: 99.99 } }

  it "створює OutboxEvent із правильними атрибутами" do
    # Ми очікуємо, що виклик .publish змінить кількість записів OutboxEvent на 1
    expect {
      described_class.publish(event_type, payload)
    }.to change(RubyOutboxGem::OutboxEvent, :count).by(1)

    # Тепер перевіримо, що створений запис має правильні дані
    event = RubyOutboxGem::OutboxEvent.last
    
    expect(event).to be_present
    expect(event.event_type).to eq(event_type)
    expect(event.payload).to eq({ "order_id" => 456, "amount" => 99.99 }) # Ключі стають рядками через JSON
    expect(event).to be_pending
    expect(event.send_at).to be_within(1.minute).of(Time.current)
  end
end