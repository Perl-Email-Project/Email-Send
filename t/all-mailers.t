use Test::More tests => 5;
use strict;
$^W = 1;

use lib 't/lib';

BEGIN { use_ok('Email::Send', 'Test'); }

my $sender  = Email::Send->new;
my @mailers = $sender->all_mailers;

ok(
  @mailers > 2, # we'll never unbundle Sendmail or SMTP
  "we found at least a couple mailers",
);

my $ok = 1;
my @mailer_pkgs;
for my $mailer (@mailers) {
  my $invocant = $sender->_mailer_invocant($mailer) or $ok = 0;
  push @mailer_pkgs, $invocant unless Scalar::Util::blessed($invocant);
}

ok($ok, "all mailers are valid mailers");

ok(
  grep({ $_ eq 'Email::Send::OK' } @mailer_pkgs),
  "we found the OK sender (from t/lib)",
);

ok(
  ! grep({ $_ eq 'Email::Send::Unavail' } @mailer_pkgs),
  "the unavailable (t/lib) sender isn't available",
);
