#!/usr/bin/env elixir
chomp = fn s -> String.replace_suffix(s, "\n", "") end
input = chomp.(File.read!("input/day12.txt"))

defmodule Climbing do
  def parse_map(input) do
    map = (input |> String.split("\n") |> Enum.map(fn row -> String.to_charlist(row) end))
    start = find(map, ?S)
    goal = find(map, ?E)
  {map |> Enum.map(fn row ->
      Enum.map(row, fn
        ?S -> ?a
        ?E -> ?z
        c -> c
      end) |> List.to_tuple
    end) |> List.to_tuple,
   start,
   goal}
  end

  defp find(haystack, needle) do
    Enum.with_index(haystack) |> Enum.find_value(fn {row, y} -> Enum.find_value(Enum.with_index(row), fn {c, x} -> if (c == needle), do: {x, y} end) end)
  end

  def scout({map, start, goal}) do
    Stream.iterate(1, &(&1 + 1))
    |> Enum.flat_map_reduce({[start], %{}}, fn
      step, {[], visited_positions} -> {:halt, {:stuck, step, visited_positions}}
      step, {positions, visited_positions} ->
        if Map.has_key?(visited_positions, goal) do
          {:halt, Map.get(visited_positions, goal)}
        else
          {[], scan(map, positions, visited_positions, step)}
        end
    end) |> elem(1)
  end

  defp scan(map, start_positions, visited_positions, step) do
    start_positions |> Enum.flat_map_reduce(visited_positions, fn position, visited_positions ->
      next_positions = reachable_positions(map, position) |> Enum.reject(fn p -> Map.has_key?(visited_positions, p) end)
      {next_positions, Enum.reduce(next_positions, visited_positions, fn p, visited_positions -> Map.put(visited_positions, p, step) end)}
    end)
  end

  defp reachable_positions(map, {x, y}) do
    h = at(map, {x, y})
    [{x, y + 1}, {x - 1, y}, {x + 1, y}, {x, y - 1}]
    |> Enum.filter(fn {x, y} -> x >= 0 and y >= 0 and y < tuple_size(map) and x < tuple_size(elem(map, 0)) end)
    |> Enum.filter(fn p -> at(map, p) <= h + 1 end)
  end

  defp at(map, {x, y}) do
    elem(elem(map, y), x)
  end

  def find_possible_starting_positions(map) do
    Enum.flat_map(0..(tuple_size(map)-1), fn y ->
      Enum.map(0..(tuple_size(elem(map, 0))-1), fn x -> {x, y} end)
    end)
    |> Enum.filter(fn p -> at(map, p) == ?a end)
  end
end

{map, start, goal} = Climbing.parse_map(input)
Climbing.scout({map, start, goal})
|> IO.inspect

Climbing.find_possible_starting_positions(map)
|> Enum.reduce(:infinity, fn start, fewest_steps ->
  steps = Climbing.scout({map, start, goal})
  min(fewest_steps, steps)
end)
|> IO.inspect
