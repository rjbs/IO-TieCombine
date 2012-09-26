#!perl
use strict;
use warnings;

use Test::More;
use IO::TieCombine;

sub test_stdout {
  my ($do, $expect, $desc) = @_;

  my $hub = IO::TieCombine->new;
  my $x = $hub->scalar_ref("x");
  tie local *STDOUT, $hub, "x";

  $do->();

  is $hub->slot_contents("x"), $expect, $desc;
}

test_stdout(
  sub {
    print "foo\n";
    print "bar\n";
  },
  "foo\nbar\n",
  'two prints; two newlines',
);

test_stdout(
  sub {
    {
      local $\ = "\n";
      print "foo\n";
    }
    print "bar\n";
  },
  "foo\n\nbar\n",
  'local output separator; default',
);

test_stdout(
  sub {
    print "foo\n";
    print "bar\n";
  },
  "foo\nbar\n",
  'two plain prints again',
);

SKIP: {
  skip 'perl >= 5.10.1 required for "say"', 1
    unless $] >= 5.010001;
  my $sub =
    eval q{sub {
      use feature 'say';
      say "foo\n";
      print "bar\n";
    }} or die $@;
  test_stdout(
    $sub,
    "foo\n\nbar\n",
    'first say, then print',
  );
}

done_testing;
