# frozen_string_literal: true

RSpec.describe RubyOutboxGem::Dispatcher do
  # Очищуємо таблицю та конфігурацію перед кожним тестом
  before do
    RubyOutboxGem::OutboxEvent.delete_all
    RubyOutboxGem.config.handlers = {} # Очищуємо обробники
  end

  # Створюємо "шпигуна" (spy) - об'єкт, який буде імітувати наш обробник
  let(:handler_spy) { double("Handler", call: true) }
  let(:event_type) { "UserCreated" }
  let(:payload) { { "user_id" => 123 } }

  # Налаштовуємо наш гем, щоб він використовував "шпигуна"
  before do
    RubyOutboxGem.configure do |config|
      config.handlers[event_type] = handler_spy
    end
  end

  context "коли подія успішно оброблена" do
    it "викликає обробник і позначає подію як 'sent'" do
      # Створюємо подію, готову до відправки
      event = RubyOutboxGem::Publisher.publish(event_type, payload)
      expect(event).to be_pending

      # Очікуємо, що наш "шпигун" отримає виклик
      expect(handler_spy).to receive(:call).with(payload)

      # Запускаємо Диспатчер
      described_class.new.call

      # Перевіряємо стан події в БД
      event.reload
      expect(event).to be_sent
      expect(event.retries_count).to eq(0)
    end
  end

  context "коли обробник видає помилку" do
    it "вмикає логіку ретраїв і не позначає як 'sent'" do
      # Створюємо подію
      event = RubyOutboxGem::Publisher.publish(event_type, payload)
      
      # Налаштовуємо "шпигуна", щоб він видавав помилку
      allow(handler_spy).to receive(:call).and_raise("Something went wrong!")

      # Запускаємо Диспатчер
      described_class.new.call

      # Перевіряємо стан події в БД
      event.reload
      expect(event).to be_pending # Має бути 'pending' для наступної спроби
      expect(event.retries_count).to eq(1)
      expect(event.send_at).to be > Time.current # Час відправки має бути в майбутньому
    end
  end
end