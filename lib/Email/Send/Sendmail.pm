package Email::Send::Sendmail;
use strict;

our $VERSION = '2.202';
$VERSION = eval $VERSION;

use File::Spec ();
BEGIN {
  local $Return::Value::NO_CLUCK = 1;
  require Return::Value;
  Return::Value->import;
}
use Symbol qw(gensym);

use vars qw[$SENDMAIL];

sub is_available {
    my $class = shift;

    # This is RIDICULOUS.  Why do we say it's available if it isn't?
    # -- rjbs, 2006-07-06
    return success "No Sendmail found" unless $class->_find_sendmail;
    return success '';
}

sub _find_sendmail {
    my $class = shift;
    return $SENDMAIL if defined $SENDMAIL;

    my $sendmail;
    for my $dir (
      File::Spec->path,
      ($ENV{PERL_EMAIL_SEND_SENDMAIL_NO_EXTRA_PATHS} ? () : (
        File::Spec->catfile('', qw(usr sbin)),
        File::Spec->catfile('', qw(usr lib)),
      ))
    ) {
        if ( -x "$dir/sendmail" ) {
            $sendmail = "$dir/sendmail";
            last;
        }
    }

    return $sendmail;
}

sub send {
    my ($class, $message, @args) = @_;
    my $mailer = $class->_find_sendmail;

    return failure "Couldn't find 'sendmail' executable in your PATH"
        ." and \$".__PACKAGE__."::SENDMAIL is not set"
        unless $mailer;

    return failure "Found $mailer but cannot execute it"
        unless -x $mailer;

    local $SIG{'CHLD'} = 'DEFAULT';

    my $pipe = gensym;

    open $pipe, "| $mailer -t -oi @args"
        or return failure "Error executing $mailer: $!";
    print $pipe $message->as_string
        or return failure "Error printing via pipe to $mailer: $!";
    close $pipe
        or return failure "error when closing pipe to $mailer: $!";
    return success;
}

1;

__END__

=head1 NAME

Email::Send::Sendmail - Send Messages using sendmail

=head1 SYNOPSIS

  use Email::Send;

  Email::Send->new({mailer => 'Sendmail'})->send($message);

=head1 DESCRIPTION

This mailer for C<Email::Send> uses C<sendmail> to send a message. It
I<does not> try hard to find the executable. It just calls
C<sendmail> and expects it to be in your path. If that's not the
case, or you want to explicitly define the location of your executable,
alter the C<$Email::Send::Sendmail::SENDMAIL> package variable.

  $Email::Send::Sendmail::SENDMAIL = '/usr/sbin/sendmail';

=head1 SEE ALSO

L<Email::Send>,
L<perl>.

=head1 AUTHOR

Casey West, <F<casey@geeknest.com>>.

=head1 CONTRIBUTORS

=over

=item *

Chase Whitener, <F<capoeirab@cpan.org>>.

=item *

Ricardo SIGNES, <F<rjbs@cpan.org>>.

=back

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2004 Casey West.  All rights reserved.

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
