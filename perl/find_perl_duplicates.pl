#!/usr/bin/env perl
use strict;
use warnings;
use YAML;
use File::Find;
use Data::Dumper;
( bless {}, __PACKAGE__ )->main();

sub main {
    my $self = shift;
    my $hash = {};
    $SIG{'INT'} = sub { exit };
    for my $inc ( grep { !/^\.\.?$/ } @INC ) {
        find {
            wanted => sub {
                return if !/\.pm\z/;
                my $a         = $File::Find::name;
                my $full_path = $a;
                $a =~ s|^\Q$inc\E/||;
                my $mod_path = $a;
                $a =~ s/\//::/g;
                $a =~ s/(.*)\.pm$/$1/g;
                $hash->{$a}->{'count'}++;
                push @{ $hash->{$a}->{'fullpath'} }, $full_path;    # if $hash->{$a}->{'count'} > 1;
            },
            no_chdir => 1
        }, $inc;
    }
    foreach my $key ( keys %{$hash} ) {
        if ( $hash->{$key}->{'count'} > 1 ) {
            foreach my $dupe ( @{ $hash->{$key}->{'fullpath'} } ) {
                #my $cmd = sprintf("pacman -Qo %s", $hash->{$key}->{$dupe});
                my $cmd = sprintf( "pacman -Qo %s", $dupe );
                my $owner = qx{ $cmd };
                chomp $owner;
                $hash->{$key}->{'dupes'}->{$dupe} = $owner;
            }
            printf(
                "%s:\nCount: %s\nPaths and Ownership:\n[ %s ]\n",
                $key,
                $hash->{$key}->{'count'},
                ( YAML::Dump( [ values %{ $hash->{$key}->{'dupes'} } ] ) )
            );
        }
    }
}
