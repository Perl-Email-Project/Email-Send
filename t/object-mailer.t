use Test::More qw[no_plan];
# $Id: classic.t,v 1.1 2006/01/17 22:11:38 cwest Exp $
use strict;
$^W =1;

BEGIN {
  use_ok 'Email::Send';
}

use Email::Send;
use lib 't/lib';

my $message = <<'.';
From: rjbs@foo.bar
To: rjbs@baz.boo
Subject: test message
Date: Thu, 2 Feb 2006 21:51:53 -0500

This is a test, a what, a test, a what, a test, oh, a test!
.

require OKMailerOO;

my $mailer1 = OKMailerOO->new;
my $mailer2 = OKMailerOO->new;

my $sender1 = Email::Send->new({ mailer => $mailer1 });
my $sender2 = Email::Send->new({ mailer => $mailer2 });

my $rv1 = $sender1->send($message);
ok($rv1, "first message sender returned success");

my $rv2 = $sender2->send($message);
ok($rv2, "second message sender returned success");

cmp_ok($rv1, '==', $mailer1, "first sender result was first mailer refaddr");
cmp_ok($rv2, '==', $mailer2, "second sender result was second mailer refaddr");
cmp_ok($rv1, '!=', $rv2,     "...and of course the two are distinct objects");
