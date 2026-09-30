# Blackjack's rules

What a hand is worth and how a round ends, for the tables at `/blackjack`
(`src/93_blackjack.blimp`, the server's Blackjack actor). The actor holds the
tables, the players and whose turn it is; everything here is a function of
cards. A port of `Blog.Games.Blackjack`.

A card is an `Int` from 0 to 51, in the order the Elixir built its deck:
suit by suit (hearts, diamonds, clubs, spades), and in each suit A, 2 ... 10,
J, Q, K. So `card % 13` is the rank and `card / 13` the suit. A hand and a
deck are `List<Int>`, the next card to deal first.

    let bj_div(a: Int, b: Int): Int { (a / b) orelse panic() }

    let bj_mod(a: Int, b: Int): Int { (a % b) orelse panic() }

    let bj_ranks: List<String> = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"];

    let bj_suits: List<String> = ["♥️", "♦️", "♣️", "♠️"];

    export let bj_rank(card: Int): String { bj_ranks[bj_mod(card, 13)] }

    export let bj_card_text(card: Int): String {
      "${bj_rank(card)}${bj_suits[bj_div(card, 13)]}"
    }

## Counting without a builder

Temper's only way to make a list longer than one it has is `ListBuilder`,
which on the Blimp backend is an actor, and actors are never collected. So
every list here is a `map` or `filter` of a slice of this one.

    let bj_upto: List<Int> = [
      0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
      13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25,
      26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38,
      39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51,
    ];

    let bj_range(n: Int): List<Int> {
      if (n < 0 || n > 52) { panic() }
      bj_upto.slice(0, n)
    }

## The deck

`Blog.Games.Blackjack.new_shuffled_deck/0` called `Enum.shuffle`. Here the
randomness comes in as a seed, so a test can deal the same shoe twice and the
Blimp caller decides where seeds come from (`random`). Each card gets a key
from a small linear congruential generator (the ZX81's: x -> (75x + 74) mod
65537, whose products fit any Int), and the deck is the cards in key order,
ties broken by card. 65536 is the generator's fixed point, so the seed is
taken mod 65536 first.

    export let bj_next_seed(seed: Int): Int { bj_mod(seed * 75 + 74, 65537) }

    let bj_nth_seed(seed: Int, n: Int): Int {
      if (n <= 0) { seed } else { bj_nth_seed(bj_next_seed(seed), n - 1) }
    }

    export let bj_shuffled_deck(seed: Int): List<Int> {
      let s0 = bj_mod(seed, 65536);
      let cards = bj_range(52);
      let keys = cards.map { (i): Int => bj_nth_seed(s0, i + 1) };
      let places = cards.map { (i): Int =>
        cards.filter { (j): Boolean => keys[j] < keys[i] || (keys[j] == keys[i] && j < i) }.length
      };
      cards.map { (p): Int => cards.filter { (i): Boolean => places[i] == p }[0] }
    }

`hand` with the first `n` cards of `deck` after it, the way `deal_cards/3`
adds to the end of a hand, and the deck that leaves. Both panic on a deck
too short, rather than deal a short hand: the caller tops the deck up first.

    export let bj_draw(hand: List<Int>, deck: List<Int>, n: Int): List<Int> {
      let h = hand.length;
      if (n > deck.length) { panic() }
      bj_range(h + n).map { (i): Int => if (i < h) { hand[i] } else { deck[i - h] } }
    }

    export let bj_rest(deck: List<Int>, n: Int): List<Int> {
      if (n > deck.length) { panic() }
      deck.slice(n, deck.length)
    }

A table of several players can run a deck dry: every hand can take up to
eleven cards. `deal_cards/3` then failed its `[card | rest_deck]` match and
took the LiveView down. Here a deck with fewer than `n` cards left is
replaced by a fresh one from `seed`, as a dealer would open a new deck: the
cards already on the table can come round again, as in a shoe of two.

    export let bj_topped(deck: List<Int>, n: Int, seed: Int): List<Int> {
      if (deck.length >= n) { deck } else { bj_shuffled_deck(seed) }
    }

## What a hand is worth

`calculate_score/1` counted every ace as 11 while that stayed at or under 21,
one ace at a time. That goes wrong when the first ace fits and a second one
does not: 10, A, A made 10 + 11 = 21, then 21 + 1 = 22, a bust, for a hand
worth 12 (`mix run` agrees: `[10, A, A] -> 22`, `[9, A, A, A] -> 22`). At
most one ace can ever count 11, since two would be 22, so the honest rule is:
every ace is 1, and one of them is 11 more if that does not bust. On every
hand the Elixir does not overcount, this is the same number.

    let bj_points(card: Int): Int {
      let r = bj_mod(card, 13);
      if (r == 0) { 1 } else if (r >= 9) { 10 } else { r + 1 }
    }

    export let bj_value(hand: List<Int>): Int {
      let hard = hand.reduceFrom(0) { (acc: Int, c: Int): Int => acc + bj_points(c) };
      let aces = hand.filter { (c): Boolean => bj_mod(c, 13) == 0 }.length;
      if (aces > 0 && hard + 10 <= 21) { hard + 10 } else { hard }
    }

A natural: 21 in the first two cards (`check_naturals/1`).

    export let bj_natural(hand: List<Int>): Boolean {
      hand.length == 2 && bj_value(hand) == 21
    }

    export let bj_busted(hand: List<Int>): Boolean { bj_value(hand) > 21 }

## Turns

A player's status is `"playing"`, `"stand"` or `"bust"`. The next to act is
the first still playing, in seat order (`activate_next_player/1`, which took
the first in map order), or -1 when nobody is.

    export let bj_next_active(statuses: List<String>): Int {
      bj_next_from(statuses, 0)
    }

    let bj_next_from(statuses: List<String>, i: Int): Int {
      if (i >= statuses.length) { -1 } else if (statuses[i] == "playing") { i } else { bj_next_from(statuses, i + 1) }
    }

The dealer plays only if somebody is still in the hand, standing or playing
(`maybe_play_dealer_turn/1`); if everyone busted, the dealer keeps two cards.

    export let bj_dealer_plays(statuses: List<String>): Boolean {
      !statuses.filter { (s): Boolean => s == "stand" || s == "playing" }.isEmpty
    }

How many cards the dealer takes from `deck`: hit while under 17, and stand
on every 17, soft or hard (`play_dealer_turn/1`).

    export let bj_dealer_draws(hand: List<Int>, deck: List<Int>): Int {
      bj_dealer_from(hand, deck, 0)
    }

    let bj_dealer_from(hand: List<Int>, deck: List<Int>, n: Int): Int {
      if (bj_value(bj_draw(hand, deck, n)) < 17) { bj_dealer_from(hand, deck, n + 1) } else { n }
    }

## How a hand ends

`determine_winners/1`, for one player: `"bust"`, `"blackjack"`, `"win"`,
`"push"` or `"lose"`. A player's natural beats anything but a dealer's
natural; against one it is a push. The Elixir paid that push nothing but
still called it `:blackjack`, so the table said "Blackjack! You win 15
chips!" and the balance did not move. A three-card 21 against a dealer's
natural is a push, as it was there.

    export let bj_outcome(player: List<Int>, dealer: List<Int>): String {
      let p = bj_value(player);
      let d = bj_value(dealer);
      if (p > 21) {
        "bust"
      } else if (bj_natural(player)) {
        if (bj_natural(dealer)) { "push" } else { "blackjack" }
      } else if (d > 21 || p > d) {
        "win"
      } else if (p == d) {
        "push"
      } else {
        "lose"
      }
    }

What an outcome does to the balance: a natural pays 3:2, rounded down as
`trunc(bet * 1.5)` did.

    export let bj_payout(outcome: String, bet: Int): Int {
      if (outcome == "blackjack") {
        bj_div(bet * 3, 2)
      } else if (outcome == "win") {
        bet
      } else if (outcome == "push") {
        0
      } else {
        -bet
      }
    }

And what the table tells the player (`maybe_show_game_over_flash/2`).

    export let bj_message(outcome: String, bet: Int): String {
      if (outcome == "bust") {
        "Bust! You lose ${bet.toString()} chips."
      } else if (outcome == "blackjack") {
        "Blackjack! You win ${bj_payout(outcome, bet).toString()} chips!"
      } else if (outcome == "win") {
        "You win ${bet.toString()} chips!"
      } else if (outcome == "push") {
        "Push - your bet is returned."
      } else if (outcome == "lose") {
        "You lose ${bet.toString()} chips."
      } else {
        "Game over!"
      }
    }
