#!/usr/bin/env elixir
chomp = fn s -> String.replace_suffix(s, "\n", "") end
input = chomp.(File.read!("input/day8.txt"))
map = (input |> String.split("\n") |> Enum.map(fn row ->to_charlist(row) |> Enum.map(&(&1 - ?0)) end))
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
    Stream.transform(row, {-1, 0}, fn tree, {tree_in_front, x} ->
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

increase_potential = fn potential, tree ->
  Enum.reduce(0..9, potential, fn i, potential ->
    put_elem(potential, i, if(i > tree, do: elem(potential, i) + 1, else: 1))
  end)
end
score = fn map ->
  Enum.map(map, fn row ->
    Enum.reduce(row, {[], {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}}, fn
      tree, {scores, potential} -> {[elem(potential, tree) | scores], increase_potential.(potential, tree)}
    end) |> elem(0)
  end)
end
scenic_scores_left = score.(map) |> Enum.map(&Enum.reverse/1)
scenic_scores_right = score.(Enum.map(map, &Enum.reverse/1))
scenic_scores_up = score.(Coll.transpose(map)) |> Enum.map(&Enum.reverse/1) |> Coll.transpose()
scenic_scores_down = score.(Coll.transpose(Enum.reverse(map))) |> Coll.transpose()
scenic_scores = (Enum.zip_reduce([scenic_scores_left, scenic_scores_right, scenic_scores_up, scenic_scores_down],
      [],
      fn scores_for_row, scores -> [Enum.zip_reduce(scores_for_row, [], &([Enum.product(&1) | &2])) | scores] end)
      |> Enum.reverse())
IO.puts(scenic_scores |> Enum.reduce(0, &(max(Enum.max(&1), &2))))
