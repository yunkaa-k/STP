# Створюємо тестовий файл big_file.txt
file_path = "big_file.txt"
File.open(file_path, "w") do |f|
  1.upto(20) do |i|
    f.puts "рядок #{i}"
  end
end

# Клас зовнішнього ітератора для читання файлу батчами
class FileBatchEnumerator
  include Enumerable

  def initialize(file_path, batch_size)
    @file_path = file_path
    @batch_size = batch_size
  end

  def each
    return enum_for(:each) unless block_given?

    batch = []
    File.foreach(@file_path) do |line|
      batch << line.chomp
      if batch.size >= @batch_size
        yield batch
        batch = []
      end
    end
    yield batch unless batch.empty?
  end
end

# Використання ітератора
file_batches = FileBatchEnumerator.new(file_path, 5)

file_batches.each do |batch|
  puts "Нова порція рядків:"
  puts batch.inspect
end