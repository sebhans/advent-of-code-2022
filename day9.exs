#!/usr/bin/env elixir
chomp = fn s -> String.replace_suffix(s, "\n", "") end
input = chomp.(File.read!("input/day9.txt"))
motions = (input |> String.split("\n") |> Enum.map(&String.split/1) |> Enum.map(fn [d, n] -> {d, String.to_integer(n)} end))
move_head = fn
  "R", {x, y} -> {x + 1, y}
  "L", {x, y} -> {x - 1, y}
  "U", {x, y} -> {x, y + 1}
  "D", {x, y} -> {x, y - 1}
end
move = fn {direction, distance}, state ->
  Enum.reduce(1..distance, state, fn _, [prev | path] ->
    [move_head.(direction, prev), prev | path]
  end)
end
head_positions = (Enum.reduce(motions, [{0, 0}], move) |> Enum.reverse)
follow = fn
  {hx, hy}, {tx, ty} when abs(hx-tx) < 2 and abs(hy-ty) < 2 -> {tx, ty}
  {hx, hy}, {tx, ty} when hx==tx -> {tx, ty + div(hy-ty, abs(hy-ty))}
  {hx, hy}, {tx, ty} when hy==ty -> {tx + div(hx-tx, abs(hx-tx)), ty}
  {hx, hy}, {tx, ty} -> {tx + div(hx-tx, abs(hx-tx)), ty + div(hy-ty, abs(hy-ty))}
end
trail = fn leader, [prev | path] -> [follow.(leader, prev), prev | path] end
trailing_positions = fn leader_positions ->
  Enum.reduce(leader_positions, [{0, 0}], trail)
  |> Enum.reverse
end
tail_positions = trailing_positions.(head_positions)
IO.inspect(tail_positions |> Enum.uniq |> length)
