#!/usr/bin/env elixir
chomp = fn s -> String.replace_suffix(s, "\n", "") end
input = chomp.(File.read!("input/day14.txt"))

defmodule Cave do
  def parse(input) do
    lines = parse_to_lines(input)
    {to_cave(lines), depth_of(lines)}
  end

  defp parse_to_lines(input) do
    String.split(input, "\n")
    |> Enum.flat_map(fn line ->
      Regex.scan(~r/([0-9]+),([0-9]+)/, line, capture: :all_but_first)
      |> Enum.map(fn match -> Enum.map(match, &String.to_integer/1) end)
      |> Enum.chunk_every(2, 1, :discard)
    end)
  end

  defp to_cave(lines) do
    Enum.reduce(lines, %{}, fn
      [[x, y1], [x, y2]], cave -> Enum.reduce(min(y1, y2)..max(y1, y2), cave, fn y, cave -> Map.put(cave, {x, y}, :rock) end)
      [[x1, y], [x2, y]], cave -> Enum.reduce(min(x1, x2)..max(x1, x2), cave, fn x, cave -> Map.put(cave, {x, y}, :rock) end)
    end)
  end

  defp depth_of(lines) do
    Enum.reduce(lines, 0, fn [[_, y1], [_, y2]], depth -> max(depth, max(y1, y2)) end)
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

  def parse_with_shadow(input) do
    lines = (parse_to_lines(input)
      |> Enum.flat_map(fn
        [[x, y1], [x, y2]] -> Enum.map(min(y1, y2)..max(y1, y2), fn y -> [[x, y], [x, y]] end)
        [[x1, y], [x2, y]] when x1 > x2 -> [[[x2, y], [x1, y]]]
        other -> [other]
      end)
      |> Enum.sort_by(fn [[_, y], _] -> y end)
      |> Enum.chunk_by(fn [[_, y], [_, y]] -> y end)
      |> Enum.reduce(%{}, fn chunk, acc ->
        [[[_, y], _] | _] = chunk
        Map.put(acc, y, chunk)
      end))
    depth = Enum.max(Map.keys(lines)) + 1
    with_shadow = (Enum.flat_map_reduce(1..depth, lines, &add_shadows/2) |> elem(0))
    {to_cave(with_shadow), depth}
  end

  defp add_shadows(y, lines) do
    merged_lines = (Map.get(lines, y, [])
      |> Enum.sort_by(fn [[x1, _], _] -> x1 end)
      |> Enum.reduce([], fn
        line, [] -> [line]
        [[x1, y], [x2, y]], [[[x3, y], [x4, y]] | rest] when x1 <= x4 + 1 -> [[[x3, y], [max(x2, x4), y]] | rest]
        other, lines -> [other | lines]
      end))
    new_shadows = Enum.flat_map(merged_lines, fn
      [[x1, y], [x2, y]] when x2 >= x1 + 2 -> [[[x1 + 1, y + 1], [x2 - 1, y + 1]]]
      _ -> []
    end)
    {merged_lines, Map.update(lines, y + 1, new_shadows, fn lines -> lines ++ new_shadows end)}
  end
end

cave = Cave.parse(input)
Cave.pour_sand(cave)
|> Cave.measure_sand
|> IO.inspect

{cave_with_shadow, depth} = Cave.parse_with_shadow(input)
sand_depth = depth + 1
IO.inspect(sand_depth/2*(2+(sand_depth-1)*2) - map_size(cave_with_shadow))
