# ------------------- UnitConverter -------------------
class UnitConverter
  # Переводимо кількість у базові одиниці
  def self.to_base(qty, unit)
    case unit
    when :g then qty
    when :kg then qty * 1000
    when :ml then qty
    when :l then qty * 1000
    when :pcs then qty
    else
      raise "Unknown unit #{unit}"
    end
  end

  # Повертаємо базову одиницю
  def self.base_for(unit)
    case unit
    when :g, :kg then :g
    when :ml, :l then :ml
    when :pcs then :pcs
    else
      raise "Unknown unit #{unit}"
    end
  end
end

# ------------------- Ingredient -------------------
class Ingredient
  attr_reader :name, :unit, :calories_per_base

  def initialize(name, unit, calories_per_base)
    @name = name.to_s
    @unit = unit
    @calories_per_base = calories_per_base.to_f
  end

  def base_unit
    UnitConverter.base_for(@unit)
  end
end

# ------------------- Recipe -------------------
class Recipe
  attr_reader :name, :steps, :items

  def initialize(name, steps = [], items = [])
    @name = name
    @steps = steps
    @items = items
  end

  def need
    res = {}
    @items.each do |it|
      ing = it[:ingredient]
      qty_in_base = UnitConverter.to_base(it[:qty], it[:unit])
      res[ing.name] ||= { qty: 0.0, unit: ing.base_unit, ingredient: ing }
      res[ing.name][:qty] += qty_in_base
    end
    res
  end
end

# ------------------- Pantry -------------------
class Pantry
  def initialize
    @stock = {}
  end

  def add(name, qty, unit)
    base_unit = UnitConverter.base_for(unit)
    qty_in_base = UnitConverter.to_base(qty, unit)
    @stock[name.to_s] ||= { qty: 0.0, unit: base_unit }
    @stock[name.to_s][:qty] += qty_in_base
  end

  def available_for(name)
    (@stock[name.to_s] && @stock[name.to_s][:qty]) || 0.0
  end
end

# ------------------- Planner -------------------
class Planner
  def self.plan(recipes, pantry, price_list = {})
    aggregated = {}

    recipes.each do |r|
      r.need.each do |name, info|
        aggregated[name] ||= { qty: 0.0, unit: info[:unit], ingredient: info[:ingredient] }
        aggregated[name][:qty] += info[:qty]
      end
    end

    total_calories = 0.0
    total_cost = 0.0

    aggregated.each do |name, info|
      ing = info[:ingredient]
      need_qty = info[:qty]
      have_qty = pantry.available_for(name)
      deficit = [need_qty - have_qty, 0].max
      calories = need_qty * ing.calories_per_base
      price = price_list[name] || 0

      # Враховуємо ВСІ потрібні інгредієнти для total cost
      cost = need_qty * price

      total_calories += calories
      total_cost += cost

      puts "#{name}: потрібно #{need_qty} #{info[:unit]}, є #{have_qty} #{info[:unit]}, дефіцит #{deficit} #{info[:unit]}"
    end

    puts "Total calories: #{total_calories.round(1)}"
    puts "Total cost: #{total_cost.round(2)}"
  end
end

# ------------------- Demo -------------------
flour = Ingredient.new("борошно", :g, 3.64)
milk = Ingredient.new("молоко", :ml, 0.06)
egg = Ingredient.new("яйце", :pcs, 72)
pasta = Ingredient.new("паста", :g, 3.5)
sauce = Ingredient.new("соус", :ml, 0.2)
cheese = Ingredient.new("сир", :g, 4.0)

omelet = Recipe.new("Омлет", [], [
  { ingredient: egg, qty: 3, unit: :pcs },
  { ingredient: milk, qty: 100, unit: :ml },
  { ingredient: flour, qty: 20, unit: :g }
])

pasta_recipe = Recipe.new("Паста", [], [
  { ingredient: pasta, qty: 200, unit: :g },
  { ingredient: sauce, qty: 150, unit: :ml },
  { ingredient: cheese, qty: 50, unit: :g }
])

pantry = Pantry.new
pantry.add("борошно", 1, :kg)   # 1000 g
pantry.add("молоко", 0.5, :l)   # 500 ml
pantry.add("яйце", 6, :pcs)
pantry.add("паста", 300, :g)
pantry.add("сир", 150, :g)

price_list = {
  "борошно" => 0.02,
  "молоко" => 0.015,
  "яйце" => 6.0,
  "паста" => 0.03,
  "соус" => 0.025,
  "сир" => 0.08
}

Planner.plan([omelet, pasta_recipe], pantry, price_list)