package Example;
use Moo;
use feature 'state';
use feature 'say';
with 'MooX::Periodic';

sub interval { 1 }

sub run {
    state $total = 0;

    $total++;

    say "example total=$total";

    die "ops" unless $total < 3;

    return $total < 5;
}

1;

package main;

Example->new->loop;
