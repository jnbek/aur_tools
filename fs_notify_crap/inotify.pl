#!/usr/bin/env perl 
use strict;
use warnings;

use Env qw(HOME);
use Data::Dumper;
use Linux::Inotify2;

( bless {}, __PACKAGE__ )->main();

sub watched_path { "$HOME/tmp/" }

sub inotify {
    shift->{'__inotify_obj'} ||= do { new Linux::Inotify2 };
}

sub main {
    my $self = shift;
    my $inotify = $self->inotify;
    # create watch
    $inotify->watch( $self->watched_path, IN_ALL_EVENTS )
      or die "watch creation failed";

    while ($inotify->poll) {
        my @events = $inotify->read;
        unless ( @events > 0 ) {
            print "read error: $!";
            last;
        }
        #printf "mask\t%s\n%s\n", $_->mask &  (IN_MODIFY | IN_CREATE | IN_DELETE),$_->name foreach @events;
        foreach my $ev (@events) {
            print sprintf("Access %s\n", $ev->name) if $ev->IN_ACCESS;
            print sprintf("Create %s\n", $ev->name) if $ev->IN_CREATE;
            print sprintf("Delete %s\n", $ev->name) if $ev->IN_DELETE;
            print sprintf("Modify %s\n", $ev->name) if $ev->IN_MODIFY;
        }
    }
    return 0;
}

