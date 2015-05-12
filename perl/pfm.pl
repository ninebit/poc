#!/usr/bin/env perl
#
# File name: pf.pl
# Date:      2015/05/11 18:11
# Author:    Kevin Miklavcic
#
#############################################################################
#

use 5.010;
use strict;
use warnings;
use Data::Dumper;
use Parallel::ForkManager;

my $p_sleep = 2;
my $c_sleep = $p_sleep * 3;
my $pfm = Parallel::ForkManager->new(2);
$pfm->run_on_finish( sub {
    my ($pid, $exit_code, $ident, $exit_signal, $core_dump, $result) = @_;
    if($result){
      print "Received: $result->{note}\n";
    }
});

foreach (0..5){
  say "wait_children();";
  $pfm->wait_children();
  say "dispatch($_)";
  dispatch($_);
  say "child $_ dispatched";
  say "sleep $p_sleep before next";
  sleep $p_sleep;
  say "iteration done\n\n";
}
say "last wait_children()";
$pfm->wait_children();

say "Wait for all children";
$pfm->wait_all_children();
say "Done!";


sub dispatch {
  my $c = shift;
  $pfm->start and return;
  say "\t\tchild $c";
  if($c == 4){
    say "\t\tchild $c sleeping for " . $c_sleep . 's';
    sleep $c_sleep;
    say "\t\tchild $c done sleeping";
  }
  my $msg;
  $msg->{note} = "child $c returning";
  $pfm->finish(0, $msg);
}

__END__

=head1 pf.pl

=head1 DESCRIPTION

=head1 USAGE

=head1 AUTHOR

  Kevin Miklavcic <kevin@9b.io>

