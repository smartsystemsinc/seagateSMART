#!/usr/bin/env perl

# Converter for Seagate's nonsense S.M.A.R.T. values
#
# Seagate's Seek Error Rate, Raw Read Error Rate, and Hardware ECC
# Recovered SMART attributes look obscenely high because of how they're
# stored; for SER, this is as a 48-bit integer in the raw state (12
# characters at 4 bits each) and needs to be converted to hex and analysed
# to get a readable number.
#
# Sources: http://sgros.blogspot.com/2013/01/seagate-disk-smart-values.html
#          http://www.users.on.net/~fzabkar/HDD/Seagate_SER_RRER_HEC.html

# Changelog:
# 0.2: Converted to include a persistent CLI and input validation.
# 0.1: Initial version. Supports conversion of SER from decimal.

use strict;
use warnings;
use Carp;                                  # Core
use English qw(-no_match_vars);            # Core
use Scalar::Util qw(looks_like_number);    # Core
use Term::UI;                              # cpan Term::UI
use Term::ReadLine;                        # cpan Term::ReadLine
our $VERSION = '0.2';

my $num = $ARGV[0];
if ($num) {
    if ( is_numeric($num) == 0 ) {
        convert($num);
        exit;
    }
    else {
        exit;
    }
}
my $term = Term::ReadLine->new('brand');
system 'clear';
LOOP:
$num = $term->get_reply(
    print_me => 'Enter a Seagate SMART value',
    prompt   => 'Value',
);
convert($num);
goto LOOP;

sub is_numeric {
    $_ = shift;
    if ( !looks_like_number($_) ) {
        print "Please enter a base-10 number\n\n" or croak $ERRNO;
        return 1;
    }
    return 0;
}

sub convert {
    my $local_num = shift;
    chomp $local_num;
    if ( $local_num =~ /exit/xmsi ) {
        print "Exiting\n" or croak $ERRNO;
        exit;
    }
    if ( is_numeric($local_num) == 1 ) {
        goto LOOP;
    }

    # Seagate's values are 48-bit so pad with zeros as necessary
    # 17262017054 should come out as 000404E57A1E
    my $hex = sprintf '%012x', $local_num;
    print "\nRaw attribute     : $hex\n" or croak $ERRNO;

    # The first 16 bytes are the total number of errors
    my $errors = substr $hex, 0, 4;
    $errors = hex $errors;

    # The last 32 bytes are the total number of occurances
    my $total = substr $hex, 4;
    $total = hex $total;

    # 000404E57A1E should come out as 4/82147870
    print "Friendly attribute: $errors/$total\n\n" or croak $ERRNO;
    return;
}

# (c) 2015 SmartSystems, Inc.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
