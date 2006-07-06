package Email::Send::Unavail;

use Test::More;

use strict;

sub is_available { 0 }

sub send {
  die "this should never be called!"; # Seriously, guys.  -- rjbs, 2006-07-06
}

1;
