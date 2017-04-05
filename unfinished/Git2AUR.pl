#!/usr/bin/env perl
use strict;
use warnings;
use Git;
use Data::Dumper;

( bless {}, __PACKAGE__ )->main();

sub main {
    my $self = shift;
    my $aur_package = $ARGV[0] || 'perl-moose';
    my $r    = sprintf(q{ssh+git://aur@aur.archlinux.org/%s.git}, $aur_package);
    #my $repo = Git->repository();
    my $repo = Git->repository( Repository => $r );
    my $refs = $repo->remote_refs($r);
    print Dumper($refs) if $refs->{'HEAD'};
}
