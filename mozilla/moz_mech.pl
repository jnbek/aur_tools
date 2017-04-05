#!/usr/bin/env perl 

use strict;
use warnings;
use Data::Dumper;
use WWW::Mechanize;

(bless {}, __PACKAGE__)->main();

sub mech { shift->{'_mech'} ||= do { WWW::Mechanize->new; }}

sub main {
    my $self = shift;
    foreach my $meth (qw(developer beta)) {
        print $meth, "\n";
        $self->$meth;
    }
    return 0;
}

sub developer {
    my $self = shift;
    my $url = 'https://download-installer.cdn.mozilla.net/pub/firefox/nightly/latest-mozilla-aurora/';
    $self->mech->get($url);
    my $linux = $self->mech->find_all_links(url_regex => qr/linux-(i686|x86_64)\.tar\.bz2$/);
    foreach my $link (@{$linux}) {
        print Dumper($link->text);
    }

    return 0;
}

sub beta {
    my $self = shift;
    my $url  = 'https://download-installer.cdn.mozilla.net/pub/firefox/candidates/';
    $self->mech->get($url);
    my @linux = $self->mech->find_all_links( url_regex => qr/^.+\/\d+\.0b\d+/ );
    my $first_half = $linux[-1]->url;
    $self->mech->follow_link(url => $linux[-1]->url);
    my @builds = $self->mech->find_all_links( url_regex => qr/build\d+/ );
    my $second_half = $builds[-1]->url;
    print $second_half,"\n";
    return 0;
}
