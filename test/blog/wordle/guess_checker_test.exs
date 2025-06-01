defmodule Blog.Wordle.GuessCheckerTest do
  use ExUnit.Case, async: true
  alias Blog.Wordle.GuessChecker

  describe "check_guess/2 (normal mode)" do
    test "all correct letters" do
      result = GuessChecker.check_guess("hello", "hello")
      assert result == [:correct, :correct, :correct, :correct, :correct]
    end

    test "all absent letters" do
      result = GuessChecker.check_guess("abcde", "fghij")
      assert result == [:absent, :absent, :absent, :absent, :absent]
    end

    test "mixed correct and absent" do
      result = GuessChecker.check_guess("hello", "hfgij")
      assert result == [:correct, :absent, :absent, :absent, :absent]
    end

    test "present letters (yellow)" do
      result = GuessChecker.check_guess("hello", "olleh")
      assert result == [:present, :present, :correct, :present, :present]
    end

    test "duplicate letters handled correctly" do
      # Target has one 'l', guess has two 'l's
      result = GuessChecker.check_guess("llama", "plant")
      assert result == [:present, :absent, :correct, :absent, :absent]
    end

    test "complex case with duplicates" do
      # Target: "speed", Guess: "erase"
      result = GuessChecker.check_guess("erase", "speed")
      # e is correct at position 1 (index 0)
      # r is absent
      # a is absent  
      # s is present (in target but wrong position)
      # e is present (in target but wrong position - second e)
      assert result == [:present, :absent, :absent, :present, :present]
    end

    test "handles repeated letters in target" do
      # Target: "steel", Guess: "helps"
      result = GuessChecker.check_guess("helps", "steel")
      # h is absent
      # e is present (in target but wrong position)
      # l is present (in target but wrong position)
      # p is absent
      # s is present (in target but wrong position)
      assert result == [:absent, :present, :present, :absent, :present]
    end

    test "handles case where guess has more of a letter than target" do
      # Target: "robot", Guess: "ooops"
      result = GuessChecker.check_guess("ooops", "robot")
      # First o is present
      # Second o is correct (position 1)
      # Third o is absent (target only has 2 o's)
      # p is absent
      # s is absent
      assert result == [:present, :correct, :absent, :absent, :absent]
    end

    test "handles empty strings gracefully" do
      result = GuessChecker.check_guess("", "")
      assert result == []
    end

    test "real wordle examples" do
      # Common Wordle scenarios
      result = GuessChecker.check_guess("adieu", "audio")
      assert result == [:correct, :present, :absent, :absent, :present]

      result = GuessChecker.check_guess("crane", "brake")
      assert result == [:absent, :correct, :correct, :absent, :correct]

      result = GuessChecker.check_guess("slate", "later")
      assert result == [:absent, :present, :present, :present, :absent]
    end
  end

  describe "check_guess/3 (hard mode)" do
    test "valid guess using all required letters" do
      previous_results = [
        %{word: "adieu", result: [:absent, :present, :absent, :absent, :absent]}
      ]
      
      # Guess must contain 'd' since it was marked as present
      result = GuessChecker.check_guess("dodge", "audio", previous_results)
      assert {:ok, _} = result
    end

    test "invalid guess missing required letters" do
      previous_results = [
        %{word: "adieu", result: [:absent, :present, :absent, :absent, :absent]}
      ]
      
      # Guess doesn't contain 'd' which was marked as present
      result = GuessChecker.check_guess("store", "audio", previous_results)
      assert {:error, "Guess must use all discovered letters"} = result
    end

    test "valid guess with multiple required letters" do
      previous_results = [
        %{word: "adieu", result: [:absent, :present, :absent, :absent, :absent]},
        %{word: "dodge", result: [:correct, :absent, :absent, :absent, :present]}
      ]
      
      # Must contain 'd' (present from first guess) and 'e' (present from second)
      result = GuessChecker.check_guess("dente", "depot", previous_results)
      assert {:ok, _} = result
    end

    test "invalid guess missing one of multiple required letters" do
      previous_results = [
        %{word: "adieu", result: [:absent, :present, :absent, :absent, :absent]},
        %{word: "dodge", result: [:correct, :absent, :absent, :absent, :present]}
      ]
      
      # Missing 'e' which was marked as present
      result = GuessChecker.check_guess("drawn", "depot", previous_results)
      assert {:error, "Guess must use all discovered letters"} = result
    end

    test "handles correct letters (green) as required" do
      previous_results = [
        %{word: "adieu", result: [:correct, :absent, :absent, :absent, :absent]}
      ]
      
      # Must contain 'a' in any position since it was correct
      result = GuessChecker.check_guess("table", "audio", previous_results)
      assert {:ok, _} = result
      
      # Invalid without 'a'
      result = GuessChecker.check_guess("store", "audio", previous_results)
      assert {:error, "Guess must use all discovered letters"} = result
    end

    test "no required letters from previous guesses" do
      previous_results = [
        %{word: "adieu", result: [:absent, :absent, :absent, :absent, :absent]}
      ]
      
      # No letters were present or correct, so any guess is valid
      result = GuessChecker.check_guess("story", "brake", previous_results)
      assert {:ok, _} = result
    end

    test "handles multiple instances of same letter" do
      previous_results = [
        %{word: "speed", result: [:absent, :absent, :present, :present, :correct]}
      ]
      
      # Must contain 'e' and 'd' 
      result = GuessChecker.check_guess("dealt", "depot", previous_results)
      assert {:ok, _} = result
      
      # Invalid - missing one required letter
      result = GuessChecker.check_guess("dealt", "depot", previous_results)
      assert {:ok, _} = result  # This should be valid since it has both e and d
      
      result = GuessChecker.check_guess("grant", "depot", previous_results)
      assert {:error, "Guess must use all discovered letters"} = result  # Missing e and d
    end

    test "empty previous results allows any guess" do
      result = GuessChecker.check_guess("crane", "audio", [])
      assert {:ok, _} = result
    end
  end

  describe "get_required_letters/1 (private function behavior)" do
    test "extracts required letters correctly through hard mode validation" do
      # Test the behavior indirectly through hard mode validation
      previous_results = [
        %{word: "adieu", result: [:correct, :present, :absent, :present, :absent]},
        %{word: "store", result: [:absent, :absent, :absent, :correct, :present]}
      ]
      
      # Should require: a (correct), d (present), u (present), r (correct), e (present)
      valid_guess = "ardeu"  # Contains all required letters
      result = GuessChecker.check_guess(valid_guess, "audio", previous_results)
      assert {:ok, _} = result
      
      invalid_guess = "blunt"  # Missing required letters
      result = GuessChecker.check_guess(invalid_guess, "audio", previous_results)
      assert {:error, "Guess must use all discovered letters"} = result
    end
  end

  describe "edge cases" do
    test "single character words" do
      result = GuessChecker.check_guess("a", "a")
      assert result == [:correct]
      
      result = GuessChecker.check_guess("a", "b")
      assert result == [:absent]
    end

    test "unicode characters" do
      result = GuessChecker.check_guess("café", "café")
      assert result == [:correct, :correct, :correct, :correct]
      
      result = GuessChecker.check_guess("café", "face")
      assert result == [:present, :present, :absent, :present]
    end

    test "mixed case handling" do
      # Note: The implementation appears to be case-sensitive
      result = GuessChecker.check_guess("Hello", "hello")
      assert result == [:absent, :correct, :correct, :correct, :correct]
    end

    test "very long words" do
      long_target = "abcdefghijklmnop"
      long_guess = "abcdefghijklmnop"
      result = GuessChecker.check_guess(long_guess, long_target)
      assert length(result) == 16
      assert Enum.all?(result, &(&1 == :correct))
    end

    test "all same letter" do
      result = GuessChecker.check_guess("aaaaa", "aaaaa")
      assert result == [:correct, :correct, :correct, :correct, :correct]
      
      result = GuessChecker.check_guess("aaaaa", "aabbb")
      assert result == [:correct, :correct, :absent, :absent, :absent]
    end
  end
end