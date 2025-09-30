def cut(cake)
  cake_matrix = cake.split("\n").map(&:chars)
  num_raisins = cake.count('o')

  # Перевірка кількості родзинок: більше 1 та менше 10
  return [] if num_raisins <= 1 || num_raisins >= 10
  # Обчислюємо загальну кількість клітинок
  total_cells = cake_matrix.length * cake_matrix[0].length
  # Перевірка чи можна розділити на рівні частини
  return [] if num_raisins == 0 || total_cells % num_raisins != 0

  slice_area = total_cells / num_raisins
  solve(cake_matrix, slice_area, num_raisins) || []
end

def trim(cake_matrix)
  # Видаляємо порожні рядки та колонки
  rows = cake_matrix.map(&:join)
  rows = rows.find_all { |row| row.strip != '' }
  first_col = rows.map { |row| row.index(/[^\s]/) }.min
  last_col = rows.map { |row| row.rindex(/[^\s]/) }.max
  
  rows.map { |row| row[first_col..last_col].chars }
end

def factor_pairs(n)
  # Знаходимо всі пари чисел, добуток яких = n
  (1..n).map { |i| [i, n / i] if n % i == 0 }.compact
end

def solve(cake_matrix, slice_area, num_raisins)
  cake_height = cake_matrix.length
  cake_width = cake_matrix[0].length
  
  start_coord = nil
  cake_matrix.each_with_index do |row, ri|
    row.each_with_index do |cell, ci|
      if cell != ' '
        start_coord = [ri, ci]
        break
      end
    end
    break if start_coord
  end
  
  return nil unless start_coord

  max_height = cake_height - start_coord[0]
  max_width = cake_width - start_coord[1]

  factor_pairs(slice_area).each do |h, w|
    next if h > max_height || w > max_width
    
    slice_matrix = cake_matrix[start_coord[0]...start_coord[0]+h].map { |r| r[start_coord[1]...start_coord[1]+w] }
    
    # Перевірка прямокутника без порожніх клітин
    next unless slice_matrix.all? { |l| l.join.tr(' ', '').length == w }
    # Перевірка, що є рівно одна родзинка
    next unless slice_matrix.join.count('o') == 1

    # Очищаємо цей шматок з решти торта
    remaining_cake = cake_matrix.each_with_index.map do |row, ridx|
      if ridx < start_coord[0] || ridx >= start_coord[0] + h
        row
      else
        row.each_with_index.map do |char, cidx|
          cidx < start_coord[1] || cidx >= start_coord[1] + w ? char : ' '
        end
      end
    end

    slice_str = slice_matrix.map(&:join).join("\n")
    
    if num_raisins == 1
      return [slice_str]
    else
      subsolve = solve(trim(remaining_cake), slice_area, num_raisins - 1)
      return [slice_str] + subsolve if subsolve
    end
  end

  nil
end

# Генерація торта
def generate_cake(rows, cols, raisins)
  # Створюємо торт з точок
  cake_matrix = Array.new(rows) { Array.new(cols, '.') }

  # Розставляємо родзинки у випадкові позиції
  raisins.times do
    loop do
      r = rand(rows)
      c = rand(cols)
      if cake_matrix[r][c] == '.'
        cake_matrix[r][c] = 'o'
        break
      end
    end
  end

  cake_matrix.map(&:join).join("\n")
end

# Запуск
cake = generate_cake(6, 6, 3)
puts "Торт:"
puts cake
puts

parts = cut(cake)

if parts.empty?
  puts "Пиріг неможливо розрізати на рівні частини"
else
  puts "Пиріг можна розрізати:"
  parts.each_with_index do |p, i|
    puts "Частина #{i+1}"
    puts p
    puts
  end
end
