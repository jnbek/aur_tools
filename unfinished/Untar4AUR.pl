#!/usr/bin/env perl 

use strict;
use warnings;
use Archive::Extract;
use Data::Dumper;

(bless {}, __PACKAGE__)->main();

sub main {
    my $self = shift;
    my $file = $ARGV[0];
    die "Use: $0 tarball.tar.gz" unless $file;
    my $ae = Archive::Extract->new( archive => $file );
     my $ok = $ae->extract( to => '/tmp' );
    print Dumper($ae,$ae->files);

    
    return 0;
}

