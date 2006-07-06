use Test::More tests => 5;
use strict;
$^W = 1;

BEGIN { use_ok('Email::Send', 'Test'); }

{ # undef message
  my $rv = send;
  ok(!$rv, "sending with no message is false");
  like("$rv", qr/no message found/i, "correct error message");
}

{ # unknown message type
  my $message = bless \(my $x = 0), "Maill::Ain't::Known";
  my $rv = send($message);
  ok(!$rv, "sending with unknown message class is false");

  # I don't like this error.  We found something, we just don't know what.
  # -- rjbs, 2006-07-06
  like("$rv", qr/no message found/i, "expected error message");
}
