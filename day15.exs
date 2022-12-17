#!/usr/bin/env elixir
chomp = fn s -> String.replace_suffix(s, "\n", "") end
input = chomp.(File.read!("input/day15.txt"))

defmodule Sensors do
  def parse(input) do
    Regex.scan(~r/Sensor at x=(-?[0-9]+), y=(-?[0-9]+): closest beacon is at x=(-?[0-9]+), y=(-?[0-9]+)/, input, capture: :all_but_first)
    |> Enum.map(fn match -> Enum.map(match, &String.to_integer/1) end)
  end

  def add_beacon_distance(sensors) do
    Enum.map(sensors, fn [sx, sy, bx, by] -> [sx, sy, bx, by, manhattan_distance(sx, sy, bx, by)] end)
  end

  defp manhattan_distance(x1, y1, x2, y2), do: abs(x1-x2) + abs(y1-y2)

  def min_max_x(sensors) do
    {Enum.min_by(sensors, &min_x/1) |> min_x,
     Enum.max_by(sensors, &max_x/1) |> max_x}
  end

  defp min_x([sx, _, _, _, d]), do: sx - d
  defp max_x([sx, _, _, _, d]), do: sx + d

  def empty?(sensors, x, y), do: in_range?(sensors, x, y) and not beacon?(sensors, x, y)

  def in_range?(sensors, x, y) do
    Enum.any?(sensors, fn [sx, sy, _, _, d] -> manhattan_distance(sx, sy, x, y) <= d end)
  end

  def beacon?(sensors, x, y) do
    Enum.any?(sensors, fn [_, _, bx, by, _] -> x == bx and y == by end)
  end

  def tuning_frequency({x, y}), do: x * 4000000 + y

  def just_out_of_range([sx, sy, _, _, d]) do
    Stream.flat_map(1..(d+1), fn dx -> [
      {sx-dx, sy-(d+1-dx)},
      {sx-dx+1, sy+d-dx+2},
      {sx+dx, sy+d+1-dx},
      {sx+dx-1, sy-d+dx-2}] end)
  end
end

sensors = (Sensors.parse(input)
  |> Sensors.add_beacon_distance)
{min_x, max_x} = Sensors.min_max_x(sensors)
IO.inspect(min_x..max_x |> Enum.count(fn x -> Sensors.empty?(sensors, x, 2000000) end))

IO.inspect(
  Stream.flat_map(sensors, fn sensor ->
    Sensors.just_out_of_range(sensor)
    |> Stream.reject(fn {x, y} -> x < 0 or x > 4000000 or y < 0 or y > 4000000 or Sensors.in_range?(sensors, x, y) end)
  end)
  |> Enum.at(0)
  |> Sensors.tuning_frequency)
