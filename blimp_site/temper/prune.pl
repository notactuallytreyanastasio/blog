#!/usr/bin/env perl
# temper/prune.pl TEMPER_BLIMP PROGRAM_FILE... > pruned.blimp
#
# The part of _build/temper.blimp a program uses: every top-level def, actor
# and binding the program's own files name, and everything those name, to a
# fixed point. Nothing else is written.
#
# The Blimp backend puts all of temper-core (about 130KB) and every module
# in one file. The server does not care. A page that downloads a program
# into blimp.wasm does: the post page's renderer is 89KB of its own and
# needs a few KB of temper-core.
#
# A top-level item starts at a line that begins in column 0 and is not a
# comment or `end`; the comments just before it go with it. An item with no
# name (`temper_run_async()`) is always kept. Names are found by matching
# identifiers outside whole-line comments and outside string text (a
# #{...} inside a string is code, and is read), so a name mentioned after code
# on a line is kept too: this can keep too much, never too little. Blimp
# cannot call a function whose name it builds at run time, so there is no
# name it can miss.
use strict;
use warnings;

my ($lib, @program) = @ARGV;
die "usage: prune.pl TEMPER_BLIMP PROGRAM_FILE...\n" unless $lib && @program;

open my $fh, '<', $lib or die "prune.pl: cannot read $lib: $!\n";
my @items;          # [name or undef, text]
my $pending = '';   # comments and blank lines waiting for the next item
while (my $line = <$fh>) {
  if ($line =~ /^(#|\s|$)/ || $line =~ /^end\b/) {
    if (@items && $line !~ /^(#|$)/) { $items[-1][1] .= $pending . $line; $pending = ''; }
    else { $pending .= $line; }
    next;
  }
  # `x = spawn C` is followed by `x <- :__new(...)`, the constructor call
  # a Temper class instance needs. That line has no name of its own; it is
  # the rest of the binding above it, and goes wherever that goes. Kept as
  # an unnamed item it was always kept, and it named `x`, so every program
  # got every module-level Temper object (std/regex's among them, once
  # Alloy brought std in): 140KB more for each program the browser loads.
  if ($line =~ /^([A-Za-z_][A-Za-z0-9_]*) <- / && @items && defined $items[-1][0] && $items[-1][0] eq $1) {
    $items[-1][1] .= $pending . $line; $pending = '';
    next;
  }
  my $name;
  if    ($line =~ /^def ([A-Za-z_][A-Za-z0-9_]*[?!]?)/) { $name = $1 }
  elsif ($line =~ /^actor ([A-Za-z_][A-Za-z0-9_]*)/)    { $name = $1 }
  elsif ($line =~ /^([A-Za-z_][A-Za-z0-9_]*) = /)       { $name = $1 }
  push @items, [$name, $pending . $line];
  $pending = '';
}
close $fh;
die "prune.pl: nothing found in $lib\n" unless @items;

my %by_name;
for my $i (0 .. $#items) {
  my $n = $items[$i][0];
  next unless defined $n;
  die "prune.pl: $n is defined twice in $lib\n" if exists $by_name{$n};
  $by_name{$n} = $i;
}

my %keep;
my @queue;
# Whole-line comments are not read for names: temper-core's comments name
# the helpers they replaced. A `#` later in a line can be inside a string
# ("&#39;"), so the rest of such a line is read, which keeps too much at worst.
# A string's text names nothing, except what is inside a #{...} in it. Read
# as words it did: Wordle's "Not in word list" once named std/regex's `Word`,
# and every browser program got the regex engine.
my $code_only = sub {
  my $t = $_[0];
  $t =~ s{"((?:[^"\\\n]|\\.)*)"}{join(" ", $1 =~ m!\#\x7b([^\x7d]*)\x7d!g)}ge;
  return $t;
};
# A word followed by one colon is a key or a declared name (`%{from: x}`,
# `state from: Int`, `become from: a`, `x: Int` in a signature), and a word
# after one is an atom (`:query`): neither refers to a def.
my $mention = sub {
  (my $text = $_[0]) =~ s/^[ \t]*#.*$//mg;
  $text = $code_only->($text);
  $text =~ s/\b[A-Za-z_][A-Za-z0-9_]*[?!]?:(?!:)/ /g;
  $text =~ s/(?<![:A-Za-z0-9_]):[A-Za-z_][A-Za-z0-9_]*[?!]?/ /g;
  for my $w ($text =~ /([A-Za-z_][A-Za-z0-9_]*[?!]?)/g) {
    my $i = $by_name{$w};
    next unless defined $i;
    next if $keep{$i}++;
    push @queue, $i;
  }
};
# A def, and a name it binds for itself (a parameter,
# or `name = ...` in its body) is not the top-level def of that name, unless
# the item also calls it: temper-core's temper_string_index_of has a local
# `from`, and with Alloy's `from` in the library that pulled the whole ORM
# into every browser program that searched a string. A program file is read
# the same way one top-level def or actor at a time, so the Markdown
# renderer's local `col` is not Alloy's either.
my $mention_item = sub {
  my $text = $_[0];
  my %local;
  if ($text =~ /^def [A-Za-z_][A-Za-z0-9_]*[?!]?\(([^)]*)\)/m) {
    my $params = $1;
    $local{$_} = 1 for $params =~ /([A-Za-z_][A-Za-z0-9_]*)\s*:/g;
  }
  $local{$1} = 1 while $text =~ /^[ \t]+([A-Za-z_][A-Za-z0-9_]*) = /mg;
  # So are a lambda's parameters, an actor's state fields and its handlers'
  # parameters.
  while ($text =~ /\bfn\(([^)]*)\)/g) {
    my $params = $1;
    $local{$_} = 1 for $params =~ /([A-Za-z_][A-Za-z0-9_]*)\s*:/g;
  }
  $local{$1} = 1 while $text =~ /^[ \t]+state ([A-Za-z_][A-Za-z0-9_]*)\s*:/mg;
  while ($text =~ /^[ \t]+on :[A-Za-z_][A-Za-z0-9_]*[?!]?\(([^)]*)\)/mg) {
    my $params = $1;
    $local{$_} = 1 for $params =~ /([A-Za-z_][A-Za-z0-9_]*)\s*:/g;
  }
  my @drop = grep { $text !~ /\b\Q$_\E\(/ } keys %local;
  if (@drop) {
    my $re = join("|", map { quotemeta } @drop);
    $text =~ s/\b(?:$re)\b(?!\()/ /g;
  }
  $mention->($text);
};
for my $f (@program) {
  open my $p, '<', $f or die "prune.pl: cannot read $f: $!\n";
  local $/; my $src = <$p> // q{}; close $p;
  $mention_item->($_) for split /(?=^(?:def|actor) )/m, $src;
}
for my $i (0 .. $#items) {
  next if defined $items[$i][0];
  $keep{$i} = 1; $mention->($items[$i][1]);
}
while (@queue) { my $i = shift @queue; $mention_item->($items[$i][1]); }

print $items[$_][1] for grep { $keep{$_} } 0 .. $#items;
