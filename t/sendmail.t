use Test::More tests => 11;
use strict;
$^W = 1;

use Cwd;
use Email::Send;
use Email::Send::Sendmail;

my $email = <<'EOF';
To:   Casey West <casey@geeknest.org>
From: Casey West <casey@geeknest.org>
Subject: This should never show up in my inbox

blah blah blah
EOF

{
  local $ENV{PATH} = '';
  ok( Email::Send::Sendmail->is_available, 'Email::Send always is available' );
  my $msg = Email::Send::Sendmail->is_available;
  is $msg, 'No Sendmail found', 'is available return value says sendmail was not found';

  my $path = Email::Send::Sendmail->_find_sendmail;
  ok( ! defined $path, 'no sendmail found because we have no path' );
}

{
  local $Email::Send::Sendmail::SENDMAIL = 'testing';
  ok( Email::Send::Sendmail->is_available, 'Email::Send is available with $SENDMAIL set' );
  my $msg = Email::Send::Sendmail->is_available;
  is( $msg, '', 'is available return message is empty with $SENDMAIL set');
}

SKIP:
{
  skip 'Cannot run unless sendmail is at /usr/sbin/sendmail', 1
    unless -x '/usr/sbin/sendmail'
      && ! -x '/usr/bin/sendmail';

  local $ENV{PATH} = '/usr/bin:/usr/sbin';
  my $path = Email::Send::Sendmail->_find_sendmail;
  is( $path, '/usr/sbin/sendmail', 'found sendmail in /usr/sbin' );
}

{
  local $Email::Send::Sendmail::SENDMAIL = './util/not-executable';
  my $sender = Email::Send->new({mailer => 'Sendmail'});
  my $return = $sender->send($email);
  ok( ! $return, "send() failed because $return" );
  like( $return, qr/cannot execute/, 'error message says what we expect' );
}

SKIP:
{
  skip 'Cannot run this test unless current perl is at /usr/bin/perl', 1
    unless -x '/usr/bin/perl' && $^X eq '/usr/bin/perl';

  local $Email::Send::Sendmail::SENDMAIL = './util/executable';
  my $sender = Email::Send->new({mailer => 'Sendmail'});
  my $return = $sender->send($email);
  ok( $return, 'send() succeeded with executable $SENDMAIL' );
}

SKIP:
{
  skip 'Cannot run this test unless current perl is at /usr/bin/perl', 2
    unless -x '/usr/bin/perl' && $^X eq '/usr/bin/perl';

  local $ENV{PATH} = './util';
  my $sender = Email::Send->new({mailer => 'Sendmail'});
  my $return = $sender->send($email);
  ok( $return, 'send() succeeded with executable sendmail in path' );

  unless ( -f 'sendmail.log' ) {
      fail( 'sendmail did not write sendmail.log' );
      last SKIP;
  }
  open my $fh, '<sendmail.log'
      or die "Cannot read sendmail.log: $!";
  my $log = join '', <$fh>;
  like( $log, qr/From: Casey West/, 'log contains From header' );
}
