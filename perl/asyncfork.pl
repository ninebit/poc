#!/usr/bin/env perl
#
# File name: f.pl
# Date:      2015/04/13 14:54
# Author:    McLovin
#
#############################################################################
#

use 5.010;
use strict;
use warnings;
use Data::Dumper;
use IPC::Run qw(start finish timeout);

my $in = '';
my $out = '';
my $err = '';
my @cmd = ('sh', '-c', 'date; sleep 5; date');
my $h = start(\@cmd, \$in, \$out, \$err);

say "Doing other stuff (aka waiting 10s)";

finish($h);

say "done - output was:";

say $out;


__END__

=head1 f.pl

=head1 DESCRIPTION

=head1 USAGE

=head1 AUTHOR

  Kevin Miklavcic <kevin@9b.io>

