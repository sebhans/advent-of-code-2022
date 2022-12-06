#!/usr/bin/env elixir
chomp = fn s -> String.replace_suffix(s, "\n", "") end
input = chomp.(File.read!("input/day6.txt"))
second = fn tuple -> elem(tuple, 1) end
marker_start = Stream.zip(Stream.chunk_every(String.to_charlist(input), 4, 1), Stream.iterate(1, &(&1 + 1)))
|> Stream.filter(&(Enum.uniq(elem(&1, 0)) == elem(&1, 0)))
|> Enum.take(1)
|> Enum.at(0)
|> second.()
IO.puts(marker_start + 3)
