#!/usr/bin/env elixir
chomp = fn s -> String.replace_suffix(s, "\n", "") end
input = chomp.(File.read!("input/day5.txt"))
{arrangement_part, procedure_part} = Enum.split_while(String.split(input, "\n"), &(String.length(&1) > 0))
arrangement = Enum.take(arrangement_part, length(arrangement_part)-1)
procedure = Enum.drop_while(procedure_part, &(String.length(&1) == 0))

num_stacks = div(String.length(List.first(arrangement))+1, 4)
next_stack = fn n -> rem(n, num_stacks)+1 end
add_crate = fn
      ?\s, {n, stacks} -> {next_stack.(n), stacks}
      crate, {n, stacks} -> {next_stack.(n), Map.put(stacks, n, [crate | stacks[n]])}
    end
add_layer = fn line, stacks -> Enum.reduce(Enum.take_every(Enum.drop(String.to_charlist(line), 1), 4), stacks, add_crate) end
empty_stacks = Enum.reduce(1..num_stacks, %{}, &(Map.put(&2, &1, [])))
initial_reversed_stacks = elem(Enum.reduce(arrangement, {1, empty_stacks}, add_layer), 1)
initial_stacks = Enum.reduce(Map.keys(initial_reversed_stacks), initial_reversed_stacks, &(Map.update!(&2, &1, fn stack -> Enum.reverse(stack) end)))

instructions = Enum.map(Enum.map(procedure, &(Regex.run(~r/move ([0-9]+) from ([0-9]+) to ([0-9]+)/, &1, capture: :all_but_first))),
  fn strings -> Enum.map(strings, &String.to_integer/1) end)
move = fn stacks, from, to -> Map.replace(Map.replace(stacks, from, Enum.drop(stacks[from], 1)), to, [List.first(stacks[from]) | stacks[to]]) end
apply = fn [count, from, to], stacks -> Enum.reduce(1..count, stacks, fn _, stacks -> move.(stacks, from, to) end) end
final_stacks = Enum.reduce(instructions, initial_stacks, &(apply.(&1, &2)))
top_crates = fn stacks -> Enum.map(1..num_stacks, &(List.first(stacks[&1]))) end
IO.puts(top_crates.(final_stacks))

apply9001 = fn [count, from, to], stacks -> Map.replace(Map.replace(stacks, from, Enum.drop(stacks[from], count)), to, Enum.take(stacks[from], count) ++ stacks[to]) end
final_stacks9001 = Enum.reduce(instructions, initial_stacks, &(apply9001.(&1, &2)))
IO.puts(top_crates.(final_stacks9001))
