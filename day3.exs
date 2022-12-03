#!/usr/bin/env elixir
chomp = fn s -> String.replace_suffix(s, "\n", "") end
input = chomp.(File.read!("input/day3.txt"))
rucksacks = Enum.map(String.split(input, "\n"), &(String.split_at(&1, div(String.length(&1), 2))))
to_set = fn c, acc -> Map.put(acc, c, true) end
ruffle = fn compartment -> Enum.reduce(Enum.uniq(String.to_charlist(compartment)), %{}, to_set) end
intersect = fn a, b -> Map.filter(a, &(Map.has_key?(b, elem(&1, 0)))) end
wrong_items = Enum.map(rucksacks, fn {a, b} -> hd(Map.keys(intersect.(ruffle.(a), ruffle.(b)))) end)
prioritize = fn
  item when item >= ?a and item <= ?z -> item - ?a + 1
  item when item >= ?A and item <= ?Z -> item - ?A + 27
end
IO.puts(Enum.sum(Enum.map(wrong_items, prioritize)))
