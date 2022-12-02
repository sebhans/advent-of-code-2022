chomp = fn s -> String.replace_suffix(s, "\n", "") end
input = chomp.(File.read!("input/day2.txt"))
input_rounds = Enum.map(String.split(input, "\n"), &(String.split(&1, " ")))
strategy_guide_guessed_key = %{"A" => :rock, "B" => :paper, "C" => :scissors, "X" => :rock, "Y" => :paper, "Z" => :scissors}
interpret = fn key -> fn [abc, xyz] -> {key[abc], key[xyz]} end end
guessed_rounds = Enum.map(input_rounds, interpret.(strategy_guide_guessed_key))
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
IO.puts(Enum.sum(Enum.map(guessed_rounds, &(score[&1]))))
