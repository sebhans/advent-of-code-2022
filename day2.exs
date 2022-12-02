chomp = fn s -> String.replace_suffix(s, "\n", "") end
input = chomp.(File.read!("input/day2.txt"))
strategy_guide_key = %{"A" => :rock, "B" => :paper, "C" => :scissors, "X" => :rock, "Y" => :paper, "Z" => :scissors}
score = %{
  {:rock, :rock} => 4,
  {:rock, :paper} => 8,
  {:rock, :scissors} => 3,
  {:paper, :rock} => 1,
  {:paper, :paper} => 5,
  {:paper, :scissors} => 9,
  {:scissors, :rock} => 7,
  {:scissors, :paper} => 2,
  {:scissors, :scissors} => 6
}
rounds = Enum.map(Enum.map(String.split(input, "\n"), &(String.split(&1, " "))), fn [abc, xyz] -> {strategy_guide_key[abc], strategy_guide_key[xyz]} end)
IO.puts(Enum.sum(Enum.map(rounds, &(score[&1]))))
