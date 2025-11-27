sum3 = ->(a, b, c) { a + b + c }

# Реалізація curry3 
def curry3(proc_or_lambda)
  # Визначаємо внутрішню рекурсивну лямбду `curried`
  curried = ->(*args_so_far) do
    # Перевірка на надлишкові аргументи
    if args_so_far.size > 3
      raise ArgumentError, "wrong number of arguments (given #{args_so_far.size}, expected 3 or fewer)"
    end

    # Якщо зібрано достатньо аргументів, викликаємо оригінальну функцію
    if args_so_far.size == 3
      return proc_or_lambda.call(*args_so_far)
    end

    # Якщо аргументів недостатньо, повертаємо нову лямбду, яка буде
    # чекати наступні аргументи і додавати їх до вже зібраних.
    return ->(*next_args) do
      # Рекурсивний виклик `curried` з об'єднаним списком аргументів
      curried.call(*(args_so_far + next_args))
    end
  end

  # Повертаємо початковий виклик `curried` без аргументів
  return curried.call()
end

# Демонстраційні виклики 
cur = curry3(sum3)

puts "cur.call(1).call(2).call(3)     #=> #{cur.call(1).call(2).call(3)}"
puts "cur.call(1, 2).call(3)          #=> #{cur.call(1, 2).call(3)}"
puts "cur.call(1).call(2, 3)          #=> #{cur.call(1).call(2, 3)}"

# Перевірка поведінки curry3(sum3).call()
cur_partial = cur.call()
puts "cur.call().call(1, 2, 3)          #=> #{cur_partial.call(1, 2, 3)}"

puts "cur.call(1, 2, 3)               #=> #{cur.call(1, 2, 3)}"

begin
  cur.call(1, 2, 3, 4)
rescue ArgumentError => e
  puts "cur.call(1, 2, 3, 4)            #=> ArgumentError (забагато)"
end

f = ->(a, b, c) { "#{a}-#{b}-#{c}" }
cF = curry3(f)
puts "cF.call('A').call('B', 'C')     #=> #{cF.call('A').call('B', 'C')}"