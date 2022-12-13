#!/usr/bin/env elixir
chomp = fn s -> String.replace_suffix(s, "\n", "") end
input = chomp.(File.read!("input/day13.txt"))

defmodule Signal do
  def parse_pairs(input) do
    input |> String.split("\n\n") |> Enum.map(fn pair -> String.split(pair, "\n") |> Enum.map(fn signal -> Code.string_to_quoted(signal) |> elem(1) end) end)
  end

  def parse_single(input) do
    input |> String.replace("\n\n", "\n") |> String.split("\n") |> Enum.map(fn signal -> Code.string_to_quoted(signal) |> elem(1) end)
  end

  def right_order?([left, right]), do: compare(left, right)

  def compare(left, right) when is_integer(left) and is_integer(right) and left < right, do: true
  def compare(left, right) when is_integer(left) and is_integer(right) and left > right, do: false
  def compare(left, right) when is_integer(left) and is_integer(right), do: nil
  def compare(left, right) when is_integer(left), do: compare([left], right)
  def compare(left, right) when is_integer(right), do: compare(left, [right])
  def compare([], []), do: nil
  def compare([], [_ | _]), do: true
  def compare([_ | _], []), do: false
  def compare([left_head | left_rest], [right_head | right_rest]) do
    case compare(left_head, right_head) do
      nil -> compare(left_rest, right_rest)
      result -> result
    end
  end
end

signal_pairs = Signal.parse_pairs(input)
signal_pairs
|> Enum.map(&Signal.right_order?/1)
|> Enum.with_index
|> Enum.filter(fn {comparison, _} -> comparison end)
|> Enum.map(&(elem(&1, 1) + 1))
|> Enum.sum
|> IO.inspect

signals = [[[2]], [[6]] | Signal.parse_single(input)]
ordered_signals = Enum.sort(signals, &(Signal.compare(&1, &2)))
ordered_signals
|> Enum.with_index
|> Enum.filter(fn {signal, _} -> signal == [[2]] or signal == [[6]] end)
|> Enum.map(&(elem(&1, 1) + 1))
|> Enum.product
|> IO.inspect
