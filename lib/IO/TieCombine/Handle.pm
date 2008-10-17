use strict;
use warnings;
package IO::TieCombine::Handle;
# ABSTRACT: tied filehandles for IO::TieCombine

use Carp ();

sub TIEHANDLE {
  my ($class, $arg) = @_;

  my $self = {
    slot_name    => $arg->{slot_name},
    combined_ref => $arg->{combined_ref},
    output_ref   => $arg->{output_ref},
  };

  return bless $self => $class;
}

sub PRINT {
  my ($self, @output) = @_;

  my $joined = join((defined $, ? $, : ''), @output);

  ${ $self->{output_ref}   } .= $joined;
  ${ $self->{combined_ref} } .= $joined;

  return 1;
}

sub PRINTF {
  my $self = shift;
  my $fmt  = shift;
  $self->PRINT(sprintf($fmt, @_));
}

sub OPEN     { return $_[0] }
sub BINMODE  { return 1; }
sub FILENO   { return 0 + $_[0] }

1;
