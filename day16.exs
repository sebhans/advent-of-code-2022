#!/usr/bin/env elixir
chomp = fn s -> String.replace_suffix(s, "\n", "") end
input = chomp.(File.read!("input/day16.txt"))

defmodule Valves do
  def parse(input) do
    Regex.scan(~r/Valve ([A-Z]+) has flow rate=([0-9]+); tunnels? leads? to valves? ([A-Z, ]+)/, input, capture: :all_but_first)
    |> Enum.map(fn [name, rate, tunnels] -> {name, String.to_integer(rate), String.split(tunnels, ", ")} end)
    |> Enum.reduce(%{}, fn valve, valves -> Map.put(valves, elem(valve, 0), valve) end)
  end

  def move(valves), do: fn {position, open, total_rate, released} ->
    {name, rate, tunnels} = Map.get(valves, position)
    open? = MapSet.member?(open, name)
    (if (not open?) and rate > 0 do
      [{position, MapSet.put(open, name), total_rate + rate, released + total_rate}]
    else
      []
    end) ++
      Enum.map(tunnels, fn tunnel -> {tunnel, open, total_rate, released + total_rate} end)
  end
end

valves = Valves.parse(input)
move = Valves.move(valves)

Enum.reduce(1..30, [{"AA", MapSet.new(), 0, 0}], fn _, paths ->
  Enum.flat_map(paths, move)
  |> Enum.sort_by(fn {position, _, total_rate, released} -> {position, total_rate, released} end, &>=/2)
  |> Enum.dedup_by(fn {position, _, total_rate, _} -> {position, total_rate} end)
end)
|> Enum.max_by(fn {_, _, _, released} -> released end)
|> elem(3)
|> IO.inspect
