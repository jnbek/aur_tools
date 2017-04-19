#!/usr/bin/env perl 

use strict;
use warnings;
use v5.10;
use Mojo::DOM;
use Data::Dumper;
use Getopt::Long;
use Mojo::UserAgent;
use WWW::AUR::Package;

( bless {}, __PACKAGE__ )->main();

sub options {
    my $self = shift;
    $self->{'release'} = 'beta';
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
    my $aur  = {
        beta   => 'firefox-beta',
        aurora => 'firefox-developer',
    };
    return $aur->{$chan};
}

sub url {
    sprintf( "https://hg.mozilla.org/releases/mozilla-%s", shift->{'release'} );
}

sub ua {
    shift->{'__mua'} ||= do { Mojo::UserAgent->new }
}

sub main {
    my $self = shift;
    $self->options;
    die "Usage: $0 --release=beta\nAcceptable Release Values: beta aurora\n" unless $self->{'release'};
    my $res = $self->ua->get( $self->url )->res;
    my $dom = Mojo::DOM->new( $res->body );
    my @links   = $dom->find('a[class="list"]')->grep($self->regex($self->{'release'}));
    say "Mozilla HG tags: ";
    foreach my $l (@links){
        my $str = $l->join("\n")->to_string;
        foreach my $href (split(/\n/, $str)) {
            $href =~ s/^.+\<b\>(.*)\<\/b\>.+$/$1/g;
            say $href;
        }
    }
    say "AUR Version: ";
    say $self->get_pkgbuild_ver;
    return 0;
}
sub get_pkgbuild_ver {
    my $self = shift;
    my $pkbd = $self->pkgbuild($self->{'release'});
    my $pkg  = WWW::AUR::Package->new($pkbd);
    say sprintf("%s: %s", $pkg->name, $pkg->version);
    return 0;
}
