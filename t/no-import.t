#!perl
use strict;
use warnings;

use lib 't/lib';

use Test::More 'no_plan';

BEGIN { use_ok('Email::Send', ()); }

my $message = <<'.';
To: casey@geeknest.com
From: foo@example.com

Blah
.

my $rv = Email::Send::send OK => $message;

ok($rv, "sender reports success");
