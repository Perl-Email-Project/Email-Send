package Email::Send::SMTP;
use strict;

use vars qw[$VERSION];
use Email::Address;
BEGIN {
  local $Return::Value::NO_CLUCK = 1;
  require Return::Value;
  Return::Value->import;
}

$VERSION = '2.198';

sub is_available {
    my ($class, %args) = @_;
    my $success = 1;
    $success = eval { require Net::SMTP };
    $success = eval { require Net::SMTP::SSL } if $args{ssl};
    $success = eval { require Net::SMTP::TLS } if $args{tls};
    return   $success
           ? success
           : failure $@;
}

sub get_env_sender {
  my ($class, $message) = @_;

  return unless my $hdr = $message->header('From');
  my $from = (Email::Address->parse($hdr))[0]->address;
}

sub get_env_recipients {
  my ($class, $message) = @_;

  my %to = map  { $_->address => 1 }
           map  { Email::Address->parse($_) }
           grep { defined and length }
           map  { $message->header($_) }
           qw(To Cc Bcc);

  return keys %to;
}

sub send {
    my ($class, $message, @args) = @_;

    my %args;
    if ( @args % 2 ) {
        my $host = shift @args;
        %args = @args;
        $args{Host} = $host;
    } else {
        %args = @args;
    }

    my $host = delete($args{Host}) || 'localhost';

    my $smtp_class = $args{ssl} ? 'Net::SMTP::SSL'
                   : $args{tls} ? 'Net::SMTP::TLS'
                   :              'Net::SMTP';

    eval "require $smtp_class; 1" or die;

    if ( $smtp_class eq 'Net::SMTP::TLS' ) {
        # ::TLS has different User/Password than the rest
        $args{User}     ||= $args{username};
        $args{Password} ||= $args{password};
    }

    my $SMTP = $smtp_class->new($host, %args);
    return failure "Couldn't connect to $host" unless $SMTP;
    
    my ($user, $pass) = @args{qw[username password]};

    # for ::TLS, the auth is done by the new()
    if ( $user and not $smtp_class eq 'Net::SMTP::TLS'  ) {
        $SMTP->auth($user, $pass)
          or return failure "Couldn't authenticate '$user:...'";
    }
    
    my @bad;
    eval {
        my $from = $class->get_env_sender($message);

        # ::TLS has no useful return value, but will croak on failure.
        eval { $SMTP->mail($from); 1 } or return failure "FROM: <$from> denied";

        my @to = $class->get_env_recipients($message);

        if (eval { $SMTP->isa('Net::SMTP::TLS') }) {
          $SMTP->to(@to);
        } else {
          my @ok = $SMTP->to(@to, { SkipBad => 1 });

          if ( @to != @ok ) {
              my %to; @to{@to} = (1) x @to;
              delete @to{@ok};
              @bad = keys %to;
          }
        }
 
        return failure "No valid recipients" if @bad == @to;
    };

    return failure $@ if $@;

    if ( $smtp_class eq 'Net::SMTP::TLS' ) {
        $SMTP->data;
        $SMTP->datasend( $message->as_string );
        $SMTP->dataend;
    }
    else {
        return failure "Can't send data" unless $SMTP->data( $message->as_string );
    }

    $SMTP->quit;
    return success "Message sent", prop => { bad => [ @bad ], };
}

1;

__END__

=head1 NAME

Email::Send::SMTP - Send Messages using SMTP

=head1 SYNOPSIS

  use Email::Send;

  my $mailer = Email::Send->new({mailer => 'SMTP'});
  
  $mailer->mailer_args([Host => 'smtp.example.com:465', ssl => 1])
    if $USE_SSL;
  
  $mailer->send($message);

=head1 DESCRIPTION

This mailer for C<Email::Send> uses C<Net::SMTP> to send a message with
an SMTP server. The first invocation of C<send> requires an SMTP server
arguments. Subsequent calls will remember the the first setting until
it is reset.

Any arguments passed to C<send> will be passed to C<< Net::SMTP->new() >>,
with some exceptions. C<username> and C<password>, if passed, are
used to invoke C<< Net::SMTP->auth() >> for SASL authentication support.
C<ssl>, if set to true, turns on SSL support by using C<Net::SMTP::SSL>.

SMTP can fail for a number of reasons. All return values from this
package are true or false. If false, sending has failed. If true,
send succeeded. The return values are C<Return::Value> objects, however,
and contain more information on just what went wrong.

Here is an example of dealing with failure.

  my $return = send SMTP => $message, 'localhost';
  
  die "$return" if ! $return;

The stringified version of the return value will have the text of the
error. In a conditional, a failure will evaluate to false.

Here's an example of dealing with success. It is the case that some
email addresses may not succeed but others will. In this case, the
return value's C<bad> property is set to a list of bad addresses.

  my $return = send SMTP => $message, 'localhost';

  if ( $return ) {
      my @bad = @{ $return->prop('bad') };
      warn "Failed to send to: " . join ', ', @bad
        if @bad;
  }

For more information on these return values, see L<Return::Value>.

=head2 ENVELOPE GENERATION

The envelope sender and recipients are, by default, generated by looking at the
From, To, Cc, and Bcc headers.  This behavior can be modified by replacing the
C<get_env_sender> and C<get_env_recipients> methods, both of which receive the
Email::Simple object and their only parameter, and return email addresses.

=head1 SEE ALSO

L<Email::Send>,
L<Net::SMTP>,
L<Net::SMTP::SSL>,
L<Email::Address>,
L<Return::Value>,
L<perl>.

=head1 AUTHOR

Current maintainer: Ricardo SIGNES, <F<rjbs@cpan.org>>.

Original author: Casey West, <F<casey@geeknest.com>>.

=head1 COPYRIGHT

  Copyright (c) 2004 Casey West.  All rights reserved.
  This module is free software; you can redistribute it and/or modify it
  under the same terms as Perl itself.

=cut
