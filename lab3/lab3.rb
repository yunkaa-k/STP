require 'digest'
require 'json'
require 'find'

# Збір даних
def find_files(root, ignore_dirs = [])
  files = []

  Find.find(root) do |path|
    if File.directory?(path)
      if ignore_dirs.include?(File.basename(path))
        Find.prune # пропускаємо цей каталог
      else
        next
      end
    else
      begin
        stat = File.stat(path)
        files << {
          path: path,
          size: stat.size,
          inode: stat.ino
        }
      rescue Errno::EACCES, Errno::ENOENT
        next
      end
    end
  end

  files
end

# Пошук потенційних дублікатів
def group_by_size(files)
  files.group_by { |f| f[:size] }.select { |_, group| group.size > 1 }
end

# Побайтна перевірка через SHA256 
def confirm_duplicates(groups)
  confirmed = []

  groups.each_value do |files|
    hash_groups = files.group_by do |f|
      begin
        Digest::SHA256.file(f[:path]).hexdigest
      rescue Errno::EACCES, Errno::ENOENT
        nil
      end
    end

    hash_groups.each do |hash, dupes|
      next if hash.nil? || dupes.size < 2

      size = dupes.first[:size]
      saved_bytes = size * (dupes.size - 1)
      confirmed << {
        size_bytes: size,
        saved_if_dedup_bytes: saved_bytes,
        files: dupes.map { |f| f[:path] }
      }
    end
  end

  confirmed
end

puts "Введіть шлях до каталогу для сканування:"
root = gets.strip
ignore = ['.git', 'node_modules', '__pycache__']

puts "Сканування каталогу..."
files = find_files(root, ignore)
puts "Знайдено #{files.size} файлів"

puts "Групування потенційних дублікатів..."
size_groups = group_by_size(files)

puts "Перевірка побайтних дублікатів..."
duplicates = confirm_duplicates(size_groups)

# Формування duplicates.json
report = {
  scanned_files: files.size,
  groups: duplicates
}

File.open("duplicates.json", "w") do |f|
  f.write(JSON.pretty_generate(report))
end

puts "Звіт збережено у duplicates.json"
puts "Знайдено #{duplicates.size} груп дублікатів."
