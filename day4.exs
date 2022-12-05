#!/usr/bin/env elixir
chomp = fn s -> String.replace_suffix(s, "\n", "") end
input = chomp.(File.read!("input/day4.txt"))
assignments = Enum.map(Regex.scan(~r/([0-9]+)-([0-9]+),([0-9]+)-([0-9]+)/, input, capture: :all_but_first),
  fn section_strings -> Enum.map(section_strings, &String.to_integer/1) end)
redundant_assignments = Enum.filter(assignments, fn [start1, end1, start2, end2] -> (start1<=start2 and end1>=end2) or (start2<=start1 and end2>=end1) end)
IO.puts(length(redundant_assignments))
