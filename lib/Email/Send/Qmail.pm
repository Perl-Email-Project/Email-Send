package Email::Send::Qmail;
# $Id: Qmail.pm,v 1.6 2006/01/28 23:02:44 cwest Exp $
use strict;

use vars qw[$QMAIL $VERSION];
$QMAIL   ||= q[qmail-inject];

use Return::Value;

$VERSION   = '2.04';

sub is_available {
    return   `which $QMAIL`
           ? success
           : failure;
}

sub send {
    my ($class, $message, @args) = @_;
    open QMAIL, "| $QMAIL @args" or return failure;
    print QMAIL $message->as_string;
    close QMAIL;
    return success;
}

1;

__END__

=head1 NAME

Email::Send::Qmail - Send Messages using qmail-inject

=head1 SYNOPSIS

  use Email::Send;

  Email::Send->new({mailer => 'Qmail'})->send($message);

=head1 DESCRIPTION

This mailer for C<Email::Send> uses C<qmail-inject> to put a message in
the Qmail spool. It I<does not> try hard to find the executable. It just
calls C<qmail-inject> and expects it to be in your path. If that's not
the case, or you want to explicitly define the location of your
executable, alter the C<$Email::Send::Qmail::QMAIL> package variable.

  $Email::Send::Qmail::QMAIL = '/usr/sbin/qmail-inject';

Any arguments passed to C<send> will be passed to C<qmail-inject>.

=head1 SEE ALSO

L<Email::Send>,
L<perl>.

=head1 AUTHOR

Casey West, <F<casey@geeknest.com>>.

=head1 COPYRIGHT

  Copyright (c) 2004 Casey West.  All rights reserved.
  This module is free software; you can redistribute it and/or modify it
  under the same terms as Perl itself.

=cut
