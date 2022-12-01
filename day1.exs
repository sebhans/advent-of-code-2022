chomp = fn s -> String.replace_suffix(s, "\n", "") end
input = chomp.(File.read!("input/day1.txt"))
input_per_elf = String.split(input, "\n\n")
calories_list = Enum.map(input_per_elf, fn s -> Enum.map(String.split(s, "\n"), &String.to_integer/1) end)
calories_sums = Enum.map(calories_list, &Enum.sum/1)
max = fn a, b -> if a >= b, do: a, else: b end
most_calories = Enum.reduce(calories_sums, max)
IO.puts(most_calories)

top3_sum = Enum.sum(Enum.take(Enum.sort(calories_sums, &(&1 >= &2)), 3))
IO.puts(top3_sum)
