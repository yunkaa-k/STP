class TextFormatter
  def format(title, content)
    "=== #{title} ===\n#{content}\n"
  end
end

class MarkdownFormatter
  def format(title, content)
    "# #{title}\n\n#{content}\n"
  end
end

class HTMLFormatter
  def format(title, content)
    "<h1>#{title}</h1>\n<p>#{content}</p>\n"
  end
end

class Report
  attr_accessor :title, :content, :formatter

  def initialize(title, content, formatter)
    @title = title
    @content = content
    @formatter = formatter
  end

  def display
    formatter.format(title, content)
  end
end

# Приклади використання
report1 = Report.new("Звіт продажів", "Продано 100 одиниць товару.", TextFormatter.new)
report2 = Report.new("Звіт продажів", "Продано 100 одиниць товару.", MarkdownFormatter.new)
report3 = Report.new("Звіт продажів", "Продано 100 одиниць товару.", HTMLFormatter.new)

puts report1.display
puts "---------------------"
puts report2.display
puts "---------------------"
puts report3.display