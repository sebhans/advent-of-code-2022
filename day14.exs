#!/usr/bin/env elixir
chomp = fn s -> String.replace_suffix(s, "\n", "") end
input = chomp.(File.read!("input/day14.txt"))

defmodule Cave do
  def parse(input) do
    String.split(input, "\n")
    |> Enum.flat_map(fn line ->
      Regex.scan(~r/([0-9]+),([0-9]+)/, line, capture: :all_but_first)
      |> Enum.map(fn match -> Enum.map(match, &String.to_integer/1) end)
      |> Enum.chunk_every(2, 1, :discard)
    end)
    |> Enum.reduce(%{}, fn
      [[x, y1], [x, y2]], cave -> Enum.reduce(min(y1, y2)..max(y1, y2), cave, fn y, cave -> Map.put(cave, {x, y}, :rock) end)
      [[x1, y], [x2, y]], cave -> Enum.reduce(min(x1, x2)..max(x1, x2), cave, fn x, cave -> Map.put(cave, {x, y}, :rock) end)
    end)
    |> add_depth
  end

  defp add_depth(cave) do
    {cave, Map.keys(cave) |> Enum.map(&(elem(&1, 1))) |> Enum.max}
  end

  def pour_sand({cave, :full}), do: cave
  def pour_sand({cave, depth}), do: pour_sand(drop_sand({cave, depth}))

  defp drop_sand({cave, depth}) do
    Stream.unfold({500, 0}, fn
      :fall_off -> nil
      {_, y} when y >= depth -> {:fall_off, :fall_off}
      {x, y} ->
      next = Enum.find([{x, y+1}, {x-1, y+1}, {x+1, y+1}], fn pos -> not Map.has_key?(cave, pos) end)
      if next, do: {next, next}, else: nil
    end)
    |> Enum.at(-1)
    |> add_to(cave, depth)
  end

  defp add_to(:fall_off, cave, _), do: {cave, :full}
  defp add_to(pos, cave, depth), do: {Map.put(cave, pos, :sand), depth}

  def measure_sand(cave), do: Map.filter(cave, &(elem(&1, 1) == :sand)) |> map_size
end

Cave.parse(input)
|> Cave.pour_sand
|> Cave.measure_sand
|> IO.inspect
