#!/usr/bin/env elixir
chomp = fn s -> String.replace_suffix(s, "\n", "") end
input = chomp.(File.read!("input/day13.txt"))

defmodule Signal do
  def parse(input) do
    input |> String.split("\n\n") |> Enum.map(fn pair -> String.split(pair, "\n") |> Enum.map(fn signal -> Code.string_to_quoted(signal) |> elem(1) end) end)
  end

  def compare_pair([left, right]) when is_integer(left) and is_integer(right) and left < right, do: :right
  def compare_pair([left, right]) when is_integer(left) and is_integer(right) and left > right, do: :wrong
  def compare_pair([left, right]) when is_integer(left) and is_integer(right), do: nil
  def compare_pair([left, right]) when is_integer(left), do: compare_pair([[left], right])
  def compare_pair([left, right]) when is_integer(right), do: compare_pair([left, [right]])
  def compare_pair([[], []]), do: nil
  def compare_pair([[], [_ | _]]), do: :right
  def compare_pair([[_ | _], []]), do: :wrong
  def compare_pair([[left_head | left_rest], [right_head | right_rest]]) do
    case compare_pair([left_head, right_head]) do
      nil -> compare_pair([left_rest, right_rest])
      result -> result
    end
  end
end

signal_pairs = Signal.parse(input)
signal_pairs
|> Enum.map(&Signal.compare_pair/1)
|> Enum.with_index
|> Enum.filter(fn {comparison, _} -> comparison == :right end)
|> Enum.map(&(elem(&1, 1) + 1))
|> Enum.sum
|> IO.inspect
