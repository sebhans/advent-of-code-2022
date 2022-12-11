#!/usr/bin/env elixir
chomp = fn s -> String.replace_suffix(s, "\n", "") end
input = chomp.(File.read!("input/day11.txt"))

defmodule Monkey do
  defp parse_operator("+"), do: &(&1 + &2)
  defp parse_operator("*"), do: &(&1 * &2)

  defp operate_on(operator, "old", "old"), do: &(operator.(&1, &1))
  defp operate_on(operator, "old", n), do: &(operator.(&1, String.to_integer(n)))

  def parse(input) do
    Regex.scan(~r/Monkey ([0-9]+):\n *Starting items: ([0-9, ]*)\n *Operation: new = ([0-9]+|old) ([*+]) ([0-9]+|old)\n *Test: divisible by ([0-9]+)\n *If true: throw to monkey ([0-9]+)\n *If false: throw to monkey ([0-9]+)/, input, capture: :all_but_first)
    |> Enum.map(fn [id,starting_items, e1, operator, e2, test_divisor, true_receiver, false_receiver] ->
      td = String.to_integer(test_divisor)
      tr = String.to_integer(true_receiver)
      fr = String.to_integer(false_receiver)
      {
        String.to_integer(id),
        Regex.scan(~r/[0-9]+/, starting_items)
        |> Enum.map(&(String.to_integer(List.first(&1)))),
        parse_operator(operator) |> operate_on(e1, e2),
        fn
          worry_level when rem(worry_level, td) == 0 -> tr
          _ -> fr
        end,
        td
      }
    end) |> Enum.to_list |> List.to_tuple
  end

  def do_rounds(monkeys, n, manage_worry) do
    Enum.reduce(1..n,
      {monkeys, Map.from_keys(Enum.to_list(0..(tuple_size(monkeys)-1)), 0)},
      fn _, state -> round(state, manage_worry) end)
  end

  defp round({monkeys, counts}, manage_worry) do
    Enum.reduce(0..tuple_size(monkeys)-1, {monkeys, counts}, fn i, {monkeys, counts} ->
      monkeys
      |> put_elem(i, put_elem(elem(monkeys, i), 1, []))
      |> monkey_around(elem(monkeys, i), counts, manage_worry)
    end)
  end

  defp monkey_around(monkeys, {id, items, inspect, sling, _}, counts, manage_worry) do
    throw_item = &(put_elem(&3, &1, put_elem(elem(&3, &1), 1, elem(elem(&3, &1), 1) ++ [&2])))
    Enum.reduce(items, {monkeys, counts}, fn item, {monkeys, counts} ->
      updated_item = (item |> inspect.() |> manage_worry.())
      {
        throw_item.(sling.(updated_item), updated_item, monkeys),
        update_in(counts, [id], &(&1 + 1))
      }
    end)
  end

  def business({_, counts}) do
    Map.values(counts)
    |> Enum.sort(&(&1 >= &2))
    |> Enum.take(2)
    |> Enum.product
  end
end

monkeys = Monkey.parse(input)
after_20_rounds = Monkey.do_rounds(monkeys, 20, &(div(&1, 3)))
IO.inspect(Monkey.business(after_20_rounds))

modulus = (Tuple.to_list(monkeys) |> Enum.map(&(elem(&1, 4))) |> Enum.product)
after_10000_rounds = Monkey.do_rounds(monkeys, 10000, &(rem(&1, modulus)))
IO.inspect(Monkey.business(after_10000_rounds))
