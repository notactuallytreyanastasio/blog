#!/usr/bin/env perl
# temper/dupes.pl FILE... : refuse a program that names something twice.
#
# Blimp has no imports; a program is its files concatenated, and a second
# top-level `def` of a name replaces the first without a word, whatever its
# arity: `def f(x)` then `def f(x, y)` leaves only the two-argument f, and
# f(1) is a WRONG ARGUMENT COUNT when it runs. The same goes for `actor A`
# and a binding `NAME = ...`. Merging chapters 72 and 69 made two bkp_body
# definitions that way, and the only sign was a test failing on the wrong
# body.
#
# A top-level name is what temper/prune.pl reads as one, at column 0:
# `def NAME`, `actor NAME`, `NAME = ...`. Defs, actors and capitalized
# bindings (constants, WEB_ROUTES) share one namespace, and each may be
# made once. A lowercase binding is the program's own script running top to
# bottom, where `routes = build_routes(posts)` then `routes =
# stack_routes(routes)` is ordinary, and every page program ends
# `fh = spawn ...; fh <- :view` (firehose_test runs three of them in one
# file). Rebinding one of those is allowed; giving one the name of a def is
# not, because the binding hides the function: after `h = 5`, h(1) is an
# UNKNOWN FUNCTION. Every clash is printed with both FILE:LINE locations,
# and the exit status is 1.
use strict;
use warnings;

die "usage: dupes.pl FILE...\n" unless @ARGV;

my %defined;   # name -> "file:line" of its def, actor or constant
my %bound;     # name -> "file:line" of its first lowercase binding
my @clashes;
for my $f (@ARGV) {
  open my $fh, '<', $f or die "dupes.pl: cannot read $f: $!\n";
  while (my $line = <$fh>) {
    my ($name, $local);
    if    ($line =~ /^def ([A-Za-z_][A-Za-z0-9_]*[?!]?)/) { $name = $1 }
    elsif ($line =~ /^actor ([A-Za-z_][A-Za-z0-9_]*)/)    { $name = $1 }
    elsif ($line =~ /^([A-Za-z_][A-Za-z0-9_]*) = /)       { $name = $1; $local = $name =~ /^[a-z_]/ }
    next unless defined $name;
    my $here = "$f:$.";
    if ($local) {
      push @clashes, "$name: $defined{$name} and $here" if exists $defined{$name} && !exists $bound{$name};
      $bound{$name} //= $here;
    } elsif (exists $defined{$name}) {
      push @clashes, "$name: $defined{$name} and $here";
    } else {
      push @clashes, "$name: $bound{$name} and $here" if exists $bound{$name};
      $defined{$name} = $here;
    }
  }
  close $fh;
}
exit 0 unless @clashes;
print STDERR "dupes.pl: a top-level name made twice (the later one silently wins):\n";
print STDERR "  $_\n" for @clashes;
exit 1;
