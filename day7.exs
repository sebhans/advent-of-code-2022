#!/usr/bin/env elixir
chomp = fn s -> String.replace_suffix(s, "\n", "") end
input = chomp.(File.read!("input/day7.txt"))
commands = (input
  |> String.replace_prefix("$ ", "")
  |> String.split("\n$ ")
  |> Enum.map(&(String.split(&1, "\n", parts: 2)))
  |> Enum.map(fn [command | output] -> {String.split(command), if(Enum.empty?(output), do: nil, else: String.split(List.first(output), "\n"))} end))

defmodule Dir do
  def cd({[_ | rest], tree}, ".."), do: {rest, tree}
  def cd({_, tree}, "/"), do: {["/"], tree}
  def cd({cwd, tree}, dir), do: {[dir | cwd], tree}

  def add_entry(["dir", dir], tree, cwd), do: put_in(tree, Enum.reverse([dir | cwd]), %{})
  def add_entry([size, file], tree, cwd), do: put_in(tree, Enum.reverse([file | cwd]), String.to_integer(size))

  def ls({cwd, tree}, entries), do: {cwd, Enum.reduce(Enum.map(entries, &String.split/1), tree, &(add_entry(&1, &2, cwd)))}

  def apply_command({["cd", dir], _}, state), do: cd(state, dir)
  def apply_command({["ls"], entries}, state), do: ls(state, entries)

  def dfs(name, dir, f) when is_map(dir) do
    dir
    |> Map.keys
    |> Enum.map(&(dfs(&1, dir[&1], f)))
    |> (&f.(name, &1)).()
  end
  def dfs(name, size, f) when is_number(size) do
    f.(name, size)
  end
  def dfs(tree, f), do: dfs("/", tree["/"], f)
end

dir_tree = Enum.reduce(commands, {["/"], %{"/" => %{}}}, &Dir.apply_command/2) |> elem(1)
dir_sizes = Dir.dfs(dir_tree, fn
  _, size when is_number(size) -> {:file, [], size}
  name, entries ->
    size = Enum.sum(Enum.map(entries, &(elem(&1, 2))))
    {:dir, [{name, size} | Enum.flat_map(entries, &(elem(&1, 1)))], size}
end) |> elem(1)
IO.inspect(dir_sizes |> Enum.map(&(elem(&1, 1))) |> Enum.filter(&(&1 <= 100000)) |> Enum.sum())

total_used_space = dir_sizes |> Enum.find(fn {name, _} -> name == "/" end) |> elem(1)
free_space = 70000000 - total_used_space
required_space = 30000000 - free_space
IO.inspect(dir_sizes |> List.keysort(1) |> Enum.find(fn {_, size} -> size >= required_space end) |> elem(1))
