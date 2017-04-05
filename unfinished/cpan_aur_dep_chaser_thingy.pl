#!/usr/bin/env perl

## NOTICE: DO NOT USE
## This script is not finished
use strict;
use warnings;

use Data::Dumper;

use ALPM;
use WWW::AUR;
use Module::CoreList;
use MetaCPAN::Client;
use CPANPLUS::Backend;
use WWW::AUR::PKGBUILD;

( bless {}, __PACKAGE__ )->main();

sub cb {
    shift->{__cb} ||= do { CPANPLUS::Backend->new; }
}

sub aur {
    shift->{__aur} ||= do { WWW::AUR->new; }
}

sub alpm {
    shift->{__alpm} ||= do { ALPM->new( '/tmp', '/var/lib/pacman' ); }
}

sub mcpan {
    shift->{__mcpan} ||= do { MetaCPAN::Client->new; }
}

sub pkgbuild {
    my $self     = shift;
    my $pkgbuild = shift;
    my $pbtext   = do { local ( @ARGV, $/ ) = $pkgbuild; <> };
    return WWW::AUR::PKGBUILD->new($pbtext);
}

sub main {
    my $self = shift;
    my $mod = $self->mcpan->release($ARGV[0]);
    my $needed = []; 
    for my $deps (@{$mod->dependency}) {
        my $module = $deps->{'module'};
        next if Module::CoreList->is_core($module);
        my $aur_mod = sprintf("perl-%s", lc($module));
        $aur_mod =~ s/\:\:/-/g;
        next if $self->alpm->search($aur_mod);
        push @{$needed}, $module unless $self->aur->find($aur_mod);
    }   
    print Dumper($needed);
    chdir("/tmp/staging_sub_exporter_glob");
    for my $module (@{$needed}) {
        print "Failed $module\n" 
            if system("/usr/bin/vendor_perl/cpan2aur $module");
    }
    return 0;
}
