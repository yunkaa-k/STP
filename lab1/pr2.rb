def play_game
  number = rand(1..100)  
  attempts = 0
  guess = 0

  puts "Я загадав число від 1 до 100. Спробуй вгадати!"

  while guess != number
    print "Введіть число: "
    guess = gets.to_i
    attempts += 1

    if guess < number
      puts "Більше!"
    elsif guess > number
      puts "Менше!"
    else
      puts "Вгадано! Число: #{number}, спроб: #{attempts}"
    end
  end
end

play_game
