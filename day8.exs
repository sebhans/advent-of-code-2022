#!/usr/bin/env elixir
chomp = fn s -> String.replace_suffix(s, "\n", "") end
input = chomp.(File.read!("input/day8.txt"))
map = (input |> String.split("\n") |> Enum.map(&to_charlist/1))
map_height = length(map)
map_width = length(List.first(map))
defmodule Coll do
  def flat_map_indexed(e, f) do
    Stream.zip(Stream.iterate(0, &(&1 + 1)), e)
    |> Stream.flat_map(f)
  end
  def transpose(([[] | _])), do: []
  def transpose(map), do: [Enum.map(map, &hd/1) | transpose(Enum.map(map, &tl/1))]
end

trees_visible_from_the_front = fn map ->
  Coll.flat_map_indexed(map, fn {y, row} ->
    Stream.transform(row, {0, 0}, fn tree, {tree_in_front, x} ->
      if tree > tree_in_front do
        {[{x, y}], {tree, x + 1}}
      else
        {[], {tree_in_front, x + 1}}
      end
    end)
  end)
end

visible_trees = (MapSet.new(trees_visible_from_the_front.(map))
  |> MapSet.union(MapSet.new(Enum.map(trees_visible_from_the_front.(Enum.map(map, &Enum.reverse/1)), fn {x, y} -> {map_width - x - 1, y} end)))
  |> MapSet.union(MapSet.new(Enum.map(trees_visible_from_the_front.(Coll.transpose(map)), fn {x, y} -> {y, x} end)))
  |> MapSet.union(MapSet.new(Enum.map(trees_visible_from_the_front.(Coll.transpose(Enum.reverse(map))), fn {x, y} -> {y, map_width - x - 1} end))))
IO.puts(MapSet.size(visible_trees))
