#!/usr/bin/env perl
use strict;
use warnings;
use Env qw(HOME);
use YAML qw(Load Dump);
use Digest::SHA;
use File::Find ();

use Data::Dumper;

use vars qw(*name *dir *prune);

( bless {}, __PACKAGE__ )->main();

sub sha { shift->{'__sha'} ||= do { Digest::SHA->new } }

sub aur4_root { "$HOME/aur4/" }

sub main {
    my $self = shift;
    $self->{'results'} = {};
    *name              = *File::Find::name;
    *dir               = *File::Find::dir;
    *prune             = *File::Find::prune;

    my $wanted = sub {
        my ( $dev, $ino, $mode, $nlink, $uid, $gid );

        ( ( $dev, $ino, $mode, $nlink, $uid, $gid ) = lstat($_) )
          && -f _
          && /^PKGBUILD\z/s
          #&& print("$name\n")
          && $self->calc_sha( $name );
    };
    my $finder = File::Find::find( { wanted => $wanted }, $self->aur4_root );
    print Dumper($self->{'results'});
}

sub calc_sha {
    my $self = shift;
    my $file = shift;
    $self->sha->addfile($file);
    $self->{'results'}->{$file} = $self->sha->hexdigest;
    return 0;
}
    
