#!/usr/bin/env perl 

use strict;
use warnings;
use v5.10;
use YAML;
use Mojo::DOM;
use Data::Dumper;
use Getopt::Long;
use Mojo::UserAgent;
use WWW::AUR::Package;

( bless {}, __PACKAGE__ )->main();

sub options {
    my $self = shift;
    my $size = GetOptions( "release|r=s" => \$self->{'release'}, );
    return $size;
}

sub regex {
    my $self = shift;
    my $chan = shift;
    my $rexs = {
        beta   => qr/FIREFOX_\d+_(\w|\d)+_BUILD\d+/,
        aurora => qr/FIREFOX_AURORA_\d+_(BASE|END)/,
    };
    return $rexs->{$chan};
}

sub pkgbuild {
    my $self = shift;
    my $chan = shift;
    my $aur  = $self->channels;
    return $aur->{$chan};
}

sub url {
    my $self = shift;
    my $chan = shift;
    return sprintf( "https://hg.mozilla.org/releases/mozilla-%s", $chan );
}

sub channels {
    {
        beta   => 'firefox-beta',
        aurora => 'firefox-developer',
    };
}

sub ua {
    shift->{'__mua'} ||= do { Mojo::UserAgent->new }
}

sub main {
    my $self = shift;
    my $opts = $self->options;
    my $hash = {};
    say "Mozilla HG tags: ";
    if ( $self->{'release'} ) {
        $hash = $self->slap_it;
    }
    else {
        my $channels = $self->channels;
        foreach my $chan ( keys %{$channels} ) {
            $hash->{$chan} = $self->slap_it($chan);
        }
    }
    print YAML::Dump($hash);
    return 0;
}

sub get_pkgbuild_ver {
    my $self = shift;
    my $chan = shift || $self->{'release'};
    my $pkbd = $self->pkgbuild($chan);
    my $pkg  = WWW::AUR::Package->new($pkbd);
    return sprintf( "%s: %s", $pkg->name, $pkg->version );
}

sub slap_it {
    my $self    = shift;
    my $chan    = shift || $self->{'release'};
    my $hash    = {};
    my $res     = $self->ua->get( $self->url($chan) )->res;
    my $dom     = Mojo::DOM->new( $res->body );
    my @links   = $dom->find('a[class="list"]')->grep( $self->regex($chan) );
    my $aur_ver = $self->get_pkgbuild_ver($chan);
    $hash->{$aur_ver} = [];
    foreach my $l (@links) {
        my $str = $l->join("\n")->to_string;
        foreach my $href ( split( /\n/, $str ) ) {
            $href =~ s/^.+\<b\>(.*)\<\/b\>.+$/$1/g;
            push @{ $hash->{$aur_ver} }, $href;
        }
    }
    return $hash;
}
