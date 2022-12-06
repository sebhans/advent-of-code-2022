#!/usr/bin/env elixir
chomp = fn s -> String.replace_suffix(s, "\n", "") end
input = chomp.(File.read!("input/day6.txt"))
second = fn tuple -> elem(tuple, 1) end
find_marker = fn marker_length ->
  Stream.zip(Stream.chunk_every(String.to_charlist(input), marker_length, 1), Stream.iterate(1, &(&1 + 1)))
  |> Stream.filter(&(Enum.uniq(elem(&1, 0)) == elem(&1, 0)))
  |> Enum.at(0)
  |> second.()
  |> Kernel.+(marker_length - 1)
end
IO.puts(find_marker.(4))
IO.puts(find_marker.(14))
