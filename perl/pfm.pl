#!/usr/bin/env perl
#
# File name: pfm.pl
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
  say "reap_any_children();";
  $pfm->reap_any_children();
  say "dispatch($_)";
  dispatch($_);
  say "child $_ dispatched";
  say "sleep $p_sleep before next";
  sleep $p_sleep;
  say "iteration done\n\n";
}
say "last reap_any_children()";
$pfm->reap_any_children();

say "Wait for all children";
$pfm->wait_all_children();
say "Done!";


sub dispatch {
  my $c = shift;
  $pfm->start; # and return;
  return if $pfm->is_parent;
  say "\t\tI'm just a child!" if $pfm->is_child;
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

=head1 pfm.pl

=head1 DESCRIPTION

In PFM, 'run_on_finish()' hooks are documented to get called only during calls to start() or wait_all_children().
In long running processes that may not have a steady stream of jobs to 'start()', 
'run_on_finish()' calls may sit for vast periods of time. Here I've tested a quick solution to reap children regularly
using the non-blocking call 'wait_children()' not presented in the docs but used by 'start()'.

=head1 USAGE

=head1 AUTHOR

  Kevin Miklavcic <kevin@9b.io>

