def word_stats(text)

  words = text.split
  count = words.size

  longest = ""
  words.each do |w|
    if w.length > longest.length
      longest = w
    end
  end

  unique_count = words.map(&:downcase).uniq.size

  puts "#{count} слів, найдовше: #{longest}, унікальних: #{unique_count}"
end

text = "Ruby is fun and ruby is powerful"
word_stats(text)