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
trail = fn
  {hx, hy}, {tx, ty} when abs(hx-tx) < 2 and abs(hy-ty) < 2 -> {tx, ty}
  {hx, hy}, {tx, ty} when hx==tx -> {tx, ty + div(hy-ty, abs(hy-ty))}
  {hx, hy}, {tx, ty} when hy==ty -> {tx + div(hx-tx, abs(hx-tx)), ty}
  {hx, hy}, {tx, ty} -> {tx + div(hx-tx, abs(hx-tx)), ty + div(hy-ty, abs(hy-ty))}
end
move = fn {direction, distance}, state ->
  Enum.reduce(1..distance, state, fn _, {{prev_head, prev_tail}, path} ->
    head = move_head.(direction, prev_head)
    tail = trail.(head, prev_tail)
    {{head, tail}, [{head, tail} | path]}
  end)
end
series = (Enum.reduce(motions, {{{0, 0}, {0, 0}}, [{{0, 0}, {0, 0}}]}, move) |> elem(1))
visited_by_tail = (Enum.map(series, &(elem(&1, 1))) |> Enum.uniq)
IO.inspect(length(visited_by_tail))
