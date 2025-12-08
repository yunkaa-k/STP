print "Введіть текст: "
str = gets.chomp

print "Введіть слово: "
reg_input = gets.chomp

regex = Regexp.new(reg_input)

if str =~ regex
  puts "Збіг знайдено!"
else
  puts "Збігів немає."
end