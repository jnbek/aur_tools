#!/usr/bin/env perl
# checkout_my_aur.pl
# CREATED:  05/02/17 14:55:59

use v5.16;
use strict;
use warnings;
use Git;
use Data::Dumper;
use Term::ANSIColor;
use Env qw(USER HOME);
use WWW::AUR::Maintainer;

( bless {}, __PACKAGE__ )->main();

sub aur_dir { "$HOME/aur4" }    #Change as needed

sub aur_user { $USER }          #Change as needed

sub remote_url { q{ssh+git://aur@aur.archlinux.org} }

sub main {
    my $self     = shift;
    my $maint    = WWW::AUR::Maintainer->new( $self->aur_user );
    my @pkgs     = $maint->packages;
    my $pkg_hash = $self->clean_dupes( \@pkgs );
    mkdir $self->aur_dir unless -d $self->aur_dir;
    foreach my $pkg_name ( keys %{$pkg_hash} ) {
        chdir $self->aur_dir || die "Chdir failed: $!";
        if ( -d $pkg_name ) {
            # This allows us to clone new PKGBUILD adoptions
            # without messing with the existing directories
            print color('bold yellow');
            print "SKIPPING";
            print color('reset');
            printf( " %s: directory exists.\n", $pkg_name );
        }
        else {
            $self->checkout_pkg($pkg_name);
        }
    }
    return 0;
}

sub checkout_pkg {
    my $self = shift;
    my $pkbd = shift;
    my $rurl = sprintf( "%s/%s.git", $self->remote_url, $pkbd );
    my $repo = Git->repository( Repository => $rurl );
    printf( "Attemping to clone %s\nUsing v%s of %s\n", $rurl, $repo->version, $repo->exec_path );
    say $repo->command( "clone", $rurl );
    return 0;
}

sub clean_dupes {
    my $self = shift;
    my $pkgs = shift;
    my $hash = {};
    foreach my $pkg ( @{$pkgs} ) {
        $hash->{ $pkg->name }++;
    }
    printf( "%d Packages to Install\n", scalar( keys %{$hash} ) );
    return $hash;
}
