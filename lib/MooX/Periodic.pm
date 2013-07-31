use strict;
use warnings;

package MooX::Periodic;

# ABSTRACT: Moo Role to provide backend to run periodic code.

use AnyEvent;
use Try::Tiny;
use Moo::Role;

requires 'run';
requires 'interval';

has 'delay' => (
    is      => 'ro',
    default => sub { 0 }
);

has '_cv' => (
    is      => 'lazy',
    default => sub { AE::cv },
    handles => {
        start => 'recv',
        stop  => 'send'
    }
);

has 'stop_on_error' => (
    is      => 'ro',
    default => sub { 1 }	
);

after on_error => sub {
	my $self = shift;
    $self->stop if $self->stop_on_error;
};

sub on_error {
    my ( $self, $exception ) = @_;

    AE::log error => "Exception: $exception";
}

sub loop {
    my ( $self, @args ) = @_;

    my $w = AE::timer $self->delay, $self->interval, sub {
        try {
            $self->run(@args);
        }
        catch {
            $self->on_error($_);
        };
    };

    $self->start;
}

1;
