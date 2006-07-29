use Test::More tests => 3;;
use strict;
$^W = 1;

use lib 't/lib';
use lib 't/no/Email-Abstract';

BEGIN { use_ok('Email::Send', 'Test'); }

{ # unknown message type
  my $message = bless \(my $x = 0), "Mail::Ain't::Known";
  my $rv = send(Test => $message);
  ok(!$rv, "sending with unknown message class is false");

  # I don't like this error.  We found something, we just don't know what.
  # -- rjbs, 2006-07-06
  like("$rv", qr/no message found/i, "expected error message");
}
