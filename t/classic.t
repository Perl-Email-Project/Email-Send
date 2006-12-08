use Test::More;
use strict;
$^W =1;

BEGIN {
  if ($^O eq 'MSWin32') {
    plan skip_all => "Patches welcome to better test Win32";
  } else {
    plan tests => 3;
  }
}

BEGIN { use_ok 'Email::Send'; }

use Email::Simple;

SKIP: {
  skip "IO::All required for these tests", 2 unless eval "use IO::All; 1";
  {
    my $message = Email::Simple->new(<<'__MESSAGE__');
To: me@myhost.com
From: you@yourhost.com
Subject: Test
    
Testing this thing out.
__MESSAGE__

    unlink 'testfile'; # just in case
    
    send('IO', $message, 'testfile');
    
    my $test = do { local $/; open T, 'testfile' or die $!; <T> };
    
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
        
    send('IO', $message_text, 'testfile');
    
    my $test = do { local $/; open T, 'testfile'; <T> };
    
    my $test_message = Email::Simple->new($test);
    
    is $test_message->as_string, $message->as_string, 'sent properly';
    
    unlink 'testfile';
  }
}
