chomp = fn s -> String.replace_suffix(s, "\n", "") end
input = chomp.(File.read!("input/day1.txt"))
input_per_elf = String.split(input, "\n\n")
calories_list = Enum.map(input_per_elf, fn s -> Enum.map(String.split(s, "\n"), &String.to_integer/1) end)
sum = fn xs -> Enum.reduce(xs, &+/2) end
max = fn a, b -> if a >= b, do: a, else: b end
most_calories = Enum.reduce(Enum.map(calories_list, sum), max)
IO.puts(most_calories)
