package Email::Send::IO;
# $Id: IO.pm,v 1.7 2006/04/20 15:39:06 cwest Exp $
use strict;

use Return::Value;

use vars qw[$VERSION];
$VERSION   = '2.04';

use vars qw[@IO];
@IO      = ('=') unless @IO;

sub is_available {
    return   eval { require IO::All }
           ? success
           : failure "is_available: Loading IO::All failed: $@";
}

sub send {
    my ($class, $message, @args) = @_;
    eval { require IO::All;IO::All->import };
    return failure "send: Loading IO::All failed: $@" if $@;
    @args = (@IO) unless @args;
    eval {io(@args)->print($message->as_string)};
    return failure $@ if $@;
    return success;
}

1;

__END__

=head1 NAME

Email::Send::IO - Send messages using IO operations

=head1 SYNOPSIS

  use Email::Send;

  my $mailer = Email::Send->new({mailer => 'IO'});

  $mailer->send($message); # To STDERR

  $mailer->mailer_args('filename.txt');
  $mailer->send($message); # write file

=head1 DESCRIPTION

This is a mailer for C<Email::Send> that will send a message using IO
operations. By default it sends mail to STDERR, very useful for debugging.
The IO functionality is built upon C<IO::All>. Any additional arguments
passed to C<send> will be used as arguments to C<IO::All::io>.

You can globally change where IO is sent by modifying the C<@Email::Send::IO::IO>
package variable.

  @Email::Send::IO::IO = ('-'); # always append to STDOUT.

=head2 Examples

Sending to STDOUT.

  send IO => $message, '-';

Send to a socket.

  send IO => $message, 'server:1337';

=head1 SEE ALSO

L<Email::Send>,
L<IO::All>,
L<perl>.

=head1 AUTHOR

Casey West, <F<casey@geeknest.com>>.

=head1 COPYRIGHT

  Copyright (c) 2005 Casey West.  All rights reserved.
  This module is free software; you can redistribute it and/or modify it
  under the same terms as Perl itself.

=cut
