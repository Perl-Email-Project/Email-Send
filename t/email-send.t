use Test::More qw[no_plan];
use strict;
$^W = 1;

use_ok 'Email::Send';
can_ok 'Email::Send', 'plugins', 'mailer_available', 'mailer',
                      'mailer_args', 'message_modifier', 'send', 'all_mailers';
use_ok $_ 
  for grep { /IO|NNTP|SMTP|Qmail|Sendmail/ } Email::Send->plugins;

can_ok $_, 'is_available', 'send'
  for grep { /IO|NNTP|SMTP|Qmail|Sendmail/ } Email::Send->plugins;

my $mailer = Email::Send->new();
isa_ok $mailer, 'Email::Send';

ok ! $mailer->mailer;
ok ! @{$mailer->mailer_args};
ok ! $mailer->message_modifier;

$mailer->mailer('SMTP');
$mailer->mailer_args([Host => 'localhost']);
$mailer->message_modifier(sub {1});

is $mailer->mailer, 'SMTP';
is $mailer->mailer_args->[1], 'localhost';
is ref($mailer->message_modifier), 'CODE';
is $mailer->message_modifier->(), 1;
