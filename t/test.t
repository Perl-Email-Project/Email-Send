use Test::More tests => 3;
use strict;
$^W =1;

BEGIN {
  use_ok 'Email::Send';
}

use Email::Simple;

if ( eval "require IO::All" ) {
    {
        my $message = Email::Simple->new(<<'__MESSAGE__');
To: me@myhost.com
From: you@yourhost.com
Subject: Test
    
Testing this thing out.
__MESSAGE__
    
        Email::Send->new({mailer => 'IO', mailer_args => ['testfile']})
                   ->send($message);
    
        my $test = do { local $/; open T, 'testfile'; <T> };
    
        my $test_message = Email::Simple->new($test);
    
        is $test_message->as_string, $message->as_string, 'sent properly';
    
        unlink 'testfile';
    }
    {
        my $message = Email::Simple->new(<<'__MESSAGE__');
To: me@myhost.com
From: you@yourhost.com
Subject: Test
    
Testing this thing out.
__MESSAGE__
    
        my $message_text = $message->as_string;
        
        Email::Send->new({mailer => 'IO', mailer_args => ['testfile']})
                   ->send($message_text);
    
        my $test = do { local $/; open T, 'testfile'; <T> };
    
        my $test_message = Email::Simple->new($test);
    
        is $test_message->as_string, $message->as_string, 'sent properly';
    
        unlink 'testfile';
    }
}
