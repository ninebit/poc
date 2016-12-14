#!/usr/bin/env perl
#
# File name: hdiff.pl
# Date:      2016/12/12 15:31
# Author:    Kevin Miklavcic
#
#############################################################################
#

use 5.010;
use strict;
use warnings;
use Carp;
use Data::Dumper;
use Hash::Merge qw(merge);
use List::MoreUtils;
use YAML::XS qw(LoadFile Load Dump);

$Data::Dumper::Sortkeys = 1;

my ($old_file, $new_file) = @ARGV;

# Expecting YAML files here...

my $old = LoadFile($old_file);
my $new = LoadFile($new_file);

#my %diff_a = %{ left_diff( $old, $new, '-' ) };
#my %diff_b = %{ left_diff( $new, $old, '+' ) };

#say "source";
#say Dumper(%diff_a);
#say "dest";
#say Dumper(%diff_b);
#my $changes = diff( \%diff_a, \%diff_b );

my $changes = diff( $old, $new );

dedupe($changes);

say Dump($changes);


# Specifically dedupe array elements
sub dedupe {
  my $href = shift;

  foreach my $item (keys %$href){
    if(ref($href->{$item}) eq 'HASH' ){
      dedupe($href->{$item});
    } elsif ( ref($href->{$item}) eq 'ARRAY' ){
      my @items = List::MoreUtils::uniq( @{$href->{$item}} );
      $href->{$item} = scalar(@items) > 1 ? [@items] : $items[0];
    } else {
      # scalar, be FREEEEE!!!!!
    }
  }
}

# 
# use Hash::Diff qw(diff left_diff);
# 
=head1 Hash::Diff

left_diff - Modified version from Hash::Diff
diff      - Modified version from Hash::Diff

=head1 ORIGINAL AUTHOR

Bjorn-Olav Strand E<lt>bo@startsiden.noE<gt>

=cut
sub left_diff {
    my ($h1, $h2, $pre) = @_;
    my $rh = {}; # return_hash
    $pre //= '';

    foreach my $k (keys %{$h1}) {
        if (not defined $h1->{$k} and exists $h2->{$k} and not defined $h2->{$k}) {
            # Empty
        }
        elsif (ref $h1->{$k} eq 'HASH') {
            if (ref $h2->{$k} eq 'HASH') {
                my $d = left_diff($h1->{$k}, $h2->{$k}, $pre);
                $rh->{$k} = $d if (%$d);
            }
            else {
                $rh->{$pre . $k} = $h1->{$k}                
            }
        }
        elsif ((!defined $h1->{$k})||(!defined $h2->{$k})||($h1->{$k} ne $h2->{$k})) {
						if( ref($h1->{$k}) =~ /HASH|ARRAY/){
            	$rh->{$pre . $k} = $h1->{$k}
						} else {
            	$rh->{$k} = $pre . $h1->{$k}
						}
        }
    }
    
    return $rh;

}

sub diff {
    my ($h1, $h2) = @_;

		Hash::Merge::set_behavior('RETAINMENT_PRECEDENT');
    return Hash::Merge::merge(left_diff($h1,$h2,'-'),left_diff($h2,$h1,'+'));
}


1;

__END__

=head1 hdiff.pl

=head1 DESCRIPTION

=head1 USAGE

=head1 AUTHOR

  Kevin Miklavcic <kmiklavcic@sourcefire.com>

