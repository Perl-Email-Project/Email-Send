use Test::More tests => 9;
use strict;
$^W = 1;

use lib 't/lib';

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

{ # broken mailers in mailer_available
  { # mailer module that won't load
    my $sender = Email::Send->new;

    my $rv = $sender->mailer_available("Test::Email::Send::Won't::Exist");
    
    ok(!$rv, "failed to load mailer (doesn't exist)"),
    like("$rv", qr/can't locate/i, "and got correct exception");
  }

  { # mailer module that won't load
    my $sender = Email::Send->new;

    my $rv = $sender->mailer_available("BadMailer");
    
    ok(!$rv, "failed to load mailer BadMailer"),
    like("$rv", qr/doesn't report avail/i, "and got correct failure");
  }
}
