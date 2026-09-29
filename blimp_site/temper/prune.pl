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
# identifiers outside whole-line comments, so a name mentioned only in a
# string or after code on a line is kept too: this can keep too much, never
# too little. Blimp cannot call a function whose name it builds at run time,
# so there is no name it can miss.
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
my $mention = sub {
  (my $text = $_[0]) =~ s/^[ \t]*#.*$//mg;
  for my $w ($text =~ /([A-Za-z_][A-Za-z0-9_]*[?!]?)/g) {
    my $i = $by_name{$w};
    next unless defined $i;
    next if $keep{$i}++;
    push @queue, $i;
  }
};
for my $f (@program) {
  open my $p, '<', $f or die "prune.pl: cannot read $f: $!\n";
  local $/; my $src = <$p> // q{}; $mention->($src); close $p;
}
for my $i (0 .. $#items) {
  next if defined $items[$i][0];
  $keep{$i} = 1; $mention->($items[$i][1]);
}
while (@queue) { my $i = shift @queue; $mention->($items[$i][1]); }

print $items[$_][1] for grep { $keep{$_} } 0 .. $#items;
