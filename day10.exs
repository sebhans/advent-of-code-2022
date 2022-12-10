#!/usr/bin/env elixir
chomp = fn s -> String.replace_suffix(s, "\n", "") end
input = chomp.(File.read!("input/day10.txt"))

defmodule CPU do
  def parse(input) do
    input |> String.split("\n") |> Stream.map(fn
      "noop" -> :noop
      addx -> {:addx, String.split(addx) |> Enum.at(1) |> String.to_integer}
    end)
  end

  def execute(:noop, x), do: [x]
  def execute({:addx, v}, x), do: [x, x + v]

  def run(instructions) do
    Stream.concat([1],
      Stream.transform(instructions, 1, fn
        instruction, x ->
          xs = execute(instruction, x)
        {xs, List.last(xs)}
      end)) |> Stream.zip(Stream.iterate(1, &(&1 + 1)))
  end
end

instructions = CPU.parse(input)
signal_strength = (CPU.run(instructions)
  |> Stream.drop(19)
  |> Stream.take_every(40)
  |> Stream.take(6)
  |> Stream.map(fn {x, n} -> x * n end)
  |> Enum.sum)
IO.inspect(signal_strength)

CPU.run(instructions)
|> Stream.each(fn
  {x, n} when abs(x - rem(n-1, 40)) <= 1 -> IO.write("#")
  _ -> IO.write(".")
end)
|> Stream.each(fn {_, n} -> if rem(n, 40)==0, do: IO.write("\n") end)
|> Stream.run
