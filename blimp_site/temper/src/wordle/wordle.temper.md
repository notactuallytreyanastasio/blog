# Wordle's rules

The rules of the game at `/wordle` (`static/wordle/wordle.blimp`), and what
the server needs to check a report from it (`src/93_wordle.blimp`): both run
these same functions, so the colours a browser shows and the colours
`/wordle_god` shows cannot disagree. A port of `Blog.Wordle.GuessChecker`,
the rule parts of `Blog.Wordle.Game`, and the target list of
`Blog.WordleWords`.

A word is a `String` of five lower-case ASCII letters. A letter's result is
a string, `"correct"`, `"present"` or `"absent"`: Temper has no atoms, and
Blimp's view compares them as strings anyway.

## Words

    let wd_lower_count(s: String, i: StringIndex, n: Int): Int {
      if (i >= s.end) {
        n
      } else {
        let c = s[i];
        if (c < 97 || c > 122) { -1 } else { wd_lower_count(s, s.next(i), n + 1) }
      }
    }

    export let wd_is_word(s: String): Boolean {
      wd_lower_count(s, String.begin, 0) == 5
    }

The five letters of a word, as one-letter strings. Every caller has asked
`wd_is_word` first; a word that is not one panics rather than being checked
as if it were.

    export let wd_letters(w: String): List<String> {
      if (!wd_is_word(w)) { panic() }
      let i1 = w.next(String.begin);
      let i2 = w.next(i1);
      let i3 = w.next(i2);
      let i4 = w.next(i3);
      [w.slice(String.begin, i1), w.slice(i1, i2), w.slice(i2, i3), w.slice(i3, i4), w.slice(i4, w.end)]
    }

A key the page was sent, as the letter it types: `"a"` for `"a"` or `"A"`,
`""` for anything else (`"Enter"`, `"é"`, `"1"`). The LiveView matched
`~r/^[a-zA-Z]$/` and downcased; Temper has no case mapping, so the letter
is cut out of an alphabet.

    export let wd_key_letter(key: String): String {
      if (key.isEmpty) {
        ""
      } else if (key.next(String.begin) < key.end) {
        ""
      } else {
        wd_lower_of(key[String.begin], key)
      }
    }

    let wd_lower_of(c: Int, key: String): String {
      let lower = "abcdefghijklmnopqrstuvwxyz";
      if (c >= 97 && c <= 122) {
        key
      } else if (c >= 65 && c <= 90) {
        let at = lower.step(String.begin, c - 65);
        lower.slice(at, lower.next(at))
      } else {
        ""
      }
    }

Whether a word is in the list of allowed guesses. The list is one string,
the words one per line with a newline before the first and after the last,
as `/wordle/words.txt` is served: asking it is one `indexOf`, which on the
Blimp backend is the interpreter's own `index_of`, not a loop.

    export let wd_valid_guess(words: String, w: String): Boolean {
      wd_is_word(w) && words.indexOf("\n${w}\n") is StringIndex
    }

## Checking a guess

`GuessChecker.do_check_guess/2` makes two passes. The first marks each
position where guess and target agree green, and deletes one copy of that
letter from a copy of the target. The second marks a letter yellow if it is
still in what is left of the target -- and then deletes it from a copy it
throws away:

```elixir
{_, true} ->
  _remaining_target = List.delete(remaining_target, char)
  :present
```

So the yellows never use a letter up. Guess `eerie` against `there`: the last
`e` is green and takes one of the two `e`s, one is left, and both leading
`e`s are yellow, where the newspaper's Wordle makes only the first one
yellow. This is the site's Wordle, so it is kept.

What is left after the first pass is the target less one copy of each green
letter, and the second pass only asks whether a letter is in it. That is a
count: a letter is still there if the target has more of it than there are
greens of it.

    let wd_count(xs: List<String>, x: String, i: Int, n: Int): Int {
      if (i >= xs.length) { n } else if (xs[i] == x) { wd_count(xs, x, i + 1, n + 1) } else { wd_count(xs, x, i + 1, n) }
    }

    let wd_greens_of(g: List<String>, t: List<String>, x: String, i: Int, n: Int): Int {
      if (i >= 5) {
        n
      } else if (g[i] == x && t[i] == x) {
        wd_greens_of(g, t, x, i + 1, n + 1)
      } else {
        wd_greens_of(g, t, x, i + 1, n)
      }
    }

    let wd_one(g: List<String>, t: List<String>, i: Int): String {
      let x = g[i];
      if (x == t[i]) {
        "correct"
      } else if (wd_count(t, x, 0, 0) > wd_greens_of(g, t, x, 0, 0)) {
        "present"
      } else {
        "absent"
      }
    }

    export let wd_check(guess: String, target: String): List<String> {
      let g = wd_letters(guess);
      let t = wd_letters(target);
      [wd_one(g, t, 0), wd_one(g, t, 1), wd_one(g, t, 2), wd_one(g, t, 3), wd_one(g, t, 4)]
    }

## Hard mode

`GuessChecker.check_guess/3`: every letter that has been green or yellow in
an earlier guess must be somewhere in this one. Only that it is somewhere:
a green letter need not stay where it was green. The earlier guesses come as
two lists, the words and their results, in the same order.

    let wd_has(xs: List<String>, x: String, i: Int): Boolean {
      if (i >= xs.length) { false } else if (xs[i] == x) { true } else { wd_has(xs, x, i + 1) }
    }

    let wd_uses_row(g: List<String>, w: List<String>, r: List<String>, i: Int): Boolean {
      if (i >= 5) {
        true
      } else if (r[i] != "absent" && !wd_has(g, w[i], 0)) {
        false
      } else {
        wd_uses_row(g, w, r, i + 1)
      }
    }

    let wd_uses_all(g: List<String>, words: List<String>, results: List<List<String>>, k: Int): Boolean {
      if (k >= words.length) {
        true
      } else if (!wd_uses_row(g, wd_letters(words[k]), results[k], 0)) {
        false
      } else {
        wd_uses_all(g, words, results, k + 1)
      }
    }

    export let wd_hard_ok(guess: String, words: List<String>, results: List<List<String>>): Boolean {
      wd_uses_all(wd_letters(guess), words, results, 0)
    }

## Submitting

What Enter does with a full row, short of changing the game: `""` if the
guess is taken, otherwise the message the LiveView showed. Not in the word
list is asked first, as `Game.submit_guess/1` did. `words` is `""` until the
page has fetched the list, and a guess made before then is refused, not
waved through.

    export let wd_refusal(guess: String, hard: Boolean, words: String, prev: List<String>, results: List<List<String>>): String {
      if (words.isEmpty) {
        "Word list still loading"
      } else if (!wd_valid_guess(words, guess)) {
        "Not in word list"
      } else if (hard && !wd_hard_ok(guess, prev, results)) {
        "Guess must use all discovered letters"
      } else {
        ""
      }
    }

The message after a guess is taken: won, lost on the sixth, or none.

    export let wd_after(guess: String, target: String, count: Int): String {
      if (guess == target) {
        "Congratulations! You won!"
      } else if (count >= 6) {
        "Game Over! The word was ${target}"
      } else {
        ""
      }
    }

## The keyboard

`Game.update_used_letters/3` only ever upgrades a key: absent, then present,
then correct. Folded over every guess that is the best result the letter
has had anywhere, so it is computed from the guesses rather than kept.
`""` for a letter not guessed yet.

    let wd_rank(r: String): Int {
      if (r == "correct") { 3 } else if (r == "present") { 2 } else if (r == "absent") { 1 } else { 0 }
    }

    let wd_best_row(x: String, w: List<String>, r: List<String>, i: Int, best: String): String {
      if (i >= 5) {
        best
      } else if (w[i] == x && wd_rank(r[i]) > wd_rank(best)) {
        wd_best_row(x, w, r, i + 1, r[i])
      } else {
        wd_best_row(x, w, r, i + 1, best)
      }
    }

    let wd_best(x: String, words: List<String>, results: List<List<String>>, k: Int, best: String): String {
      if (k >= words.length) {
        best
      } else {
        wd_best(x, words, results, k + 1, wd_best_row(x, wd_letters(words[k]), results[k], 0, best))
      }
    }

    export let wd_key_status(letter: String, words: List<String>, results: List<List<String>>): String {
      wd_best(letter, words, results, 0, "")
    }

## Time

`format_time_ago/1`, from a number of seconds (the server stamps each game;
the WebAssembly build has no clock).

    export let wd_ago(seconds: Int): String {
      if (seconds < 60) {
        "just now"
      } else if (seconds < 3600) {
        "${((seconds / 60) orelse panic()).toString()} min ago"
      } else if (seconds < 86400) {
        "${((seconds / 3600) orelse panic()).toString()} hours ago"
      } else {
        "${((seconds / 86400) orelse panic()).toString()} days ago"
      }
    }

`/wordle_god`'s left border: green inside five minutes, yellow inside the
hour, orange inside the day.

    export let wd_activity_class(seconds: Int): String {
      if (seconds < 300) {
        "border-l-4 border-green-500"
      } else if (seconds < 3600) {
        "border-l-4 border-yellow-500"
      } else if (seconds < 86400) {
        "border-l-4 border-orange-300"
      } else {
        "border-l-4 border-gray-300"
      }
    }

`round(won / completed * 100)`, in integers: half rounds up, as Elixir's
`round/1` does for a positive number.

    export let wd_win_rate(won: Int, completed: Int): Int {
      if (completed <= 0) { 0 } else { ((won * 200 + completed) / (2 * completed)) orelse panic() }
    }

## Targets

`Blog.WordleWords.potential_words/0` is 531 words. Two of them could never
be won: `dish` has four letters, and `april` is not in the list of allowed
guesses, so typing it answers "Not in word list". The LiveView dealt both
out. These are the other 529.

    export let wd_answers: List<String> = [
      "about", "actor", "adapt", "admit", "adult", "agent", "agree", "ahead", "alarm", "album", 
      "alert", "alien", "allow", "alone", "along", "alter", "among", "anger", "angle", "angry", 
      "ankle", "apple", "apply", "arena", "argue", "arise", "array", "arrow", "asset", "audio", 
      "avoid", "award", "aware", "awful", "bacon", "badge", "baker", "basic", "basin", "basis", 
      "batch", "beach", "beard", "begin", "being", "below", "bench", "berry", "birth", "black", 
      "blade", "blame", "blank", "blast", "blend", "blind", "block", "blood", "board", "boost", 
      "booth", "bound", "brain", "brake", "brand", "brass", "brave", "bread", "break", "breed", 
      "brief", "bring", "broad", "brush", "buddy", "build", "bunch", "burst", "cabin", "cable", 
      "cache", "candy", "cargo", "carry", "catch", "cause", "chain", "chair", "chalk", "charm", 
      "chart", "chase", "cheap", "check", "chest", "chief", "child", "china", "claim", "class", 
      "clean", "clear", "click", "clock", "close", "cloud", "coach", "coast", "color", "comic", 
      "count", "court", "cover", "craft", "crash", "cream", "crime", "cross", "crowd", "crown", 
      "curve", "cycle", "daily", "dance", "dated", "death", "debug", "delay", "depth", "digit", 
      "dirty", "dodge", "doubt", "draft", "drain", "drama", "dream", "dress", "drift", "drink", 
      "drive", "drone", "early", "earth", "eight", "elite", "empty", "enemy", "enjoy", "enter", 
      "entry", "equal", "error", "event", "exact", "exist", "extra", "fable", "faith", "false", 
      "fancy", "fatal", "fault", "favor", "feast", "field", "fight", "final", "first", "flame", 
      "flash", "fleet", "float", "flood", "floor", "flour", "focus", "force", "forge", "forth", 
      "found", "frame", "fresh", "front", "frost", "fruit", "fully", "funny", "gauge", "ghost", 
      "giant", "given", "glass", "globe", "glory", "grace", "grade", "grain", "grant", "grass", 
      "grave", "great", "green", "grind", "group", "guard", "guess", "guest", "guide", "happy", 
      "harsh", "heart", "heavy", "hedge", "hello", "honor", "horse", "hotel", "house", "human", 
      "ideal", "image", "index", "inner", "input", "issue", "ivory", "jeans", "joint", "judge", 
      "juice", "known", "label", "labor", "large", "laser", "later", "laugh", "layer", "learn", 
      "lease", "least", "leave", "legal", "level", "light", "limit", "local", "lodge", "logic", 
      "loose", "lower", "lucky", "lunch", "magic", "major", "maker", "march", "match", "maybe", 
      "medal", "media", "mercy", "merit", "metal", "might", "minor", "model", "money", "month", 
      "moral", "motor", "mount", "mouse", "mouth", "movie", "music", "naive", "naval", "nerve", 
      "never", "night", "noble", "noise", "north", "novel", "nurse", "ocean", "offer", "olive", 
      "onset", "opera", "order", "other", "outer", "owner", "paint", "panel", "paper", "party", 
      "patch", "pause", "peace", "phase", "phone", "photo", "piano", "piece", "pilot", "pitch", 
      "pizza", "place", "plain", "plane", "plant", "plate", "point", "power", "press", "price", 
      "pride", "prime", "print", "prior", "prize", "probe", "proof", "proud", "pulse", "punch", 
      "puppy", "queen", "query", "quiet", "quite", "quote", "radar", "radio", "raise", "rally", 
      "ranch", "range", "rapid", "ratio", "reach", "ready", "refer", "right", "rival", "river", 
      "robot", "rough", "round", "route", "royal", "rugby", "rural", "sadly", "saint", "sauce", 
      "scale", "scare", "scene", "scope", "score", "scout", "scrap", "sense", "serve", "shade", 
      "shaft", "shake", "shall", "shape", "share", "sharp", "sheep", "sheet", "shelf", "shell", 
      "shift", "shine", "shirt", "shock", "shoot", "shore", "short", "shout", "sight", "silly", 
      "skill", "skirt", "skull", "sleep", "slice", "slide", "slope", "smart", "smell", "smile", 
      "smoke", "snake", "solar", "solid", "solve", "sorry", "sound", "south", "space", "spare", 
      "spark", "speak", "speed", "spell", "spend", "spike", "split", "sport", "spray", "stack", 
      "staff", "stage", "stair", "stake", "stand", "start", "state", "steam", "steel", "stick", 
      "still", "stock", "stone", "store", "storm", "story", "strip", "study", "stuff", "style", 
      "sugar", "suite", "sunny", "super", "sweet", "swift", "swing", "sword", "table", "taste", 
      "teach", "theme", "there", "thick", "thing", "think", "third", "those", "three", "throw", 
      "thumb", "tiger", "title", "today", "token", "tooth", "topic", "total", "touch", "tough", 
      "tower", "trace", "track", "trade", "trail", "train", "treat", "trend", "trial", "tribe", 
      "trick", "troop", "truck", "trust", "truth", "twice", "twist", "uncle", "under", "unity", 
      "upper", "upset", "urban", "usage", "usual", "valid", "value", "video", "virus", "visit", 
      "vital", "voice", "voter", "waste", "watch", "water", "weird", "whale", "wheat", "wheel", 
      "where", "which", "while", "white", "whole", "whose", "widow", "width", "world", "worry", 
      "worth", "wound", "write", "wrong", "yacht", "yield", "young", "youth", "zebra",
    ];

The target for a random number `n` (Blimp's `random`, seeded by the page).

    export let wd_target(n: Int): String {
      wd_answers[(n % wd_answers.length) orelse panic()]
    }
