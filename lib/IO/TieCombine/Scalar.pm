use strict;
use warnings;
package IO::TieCombine::Scalar;

use Carp ();

sub TIESCALAR {
  my ($class, $arg) = @_;

  my $self = {
    slot_name    => $arg->{slot_name},
    combined_ref => $arg->{combined_ref},
    output_ref   => $arg->{output_ref},
  };

  bless $self => $class;
}

sub FETCH {
  return ${ $_[0]->{output_ref} }
}

sub STORE {
  my ($self, $value) = @_;
  my $class = ref $self;
  my $output_ref = $self->{output_ref};

  Carp::croak "you may only append, not reassign, a $class tie"
    unless index($value, $$output_ref) == 0;
  
  my $extra = substr $value, length $$output_ref, length $value;

  printf "appending <%s> to <%s>\n", $extra, $self->{slot_name};

  ${ $self->{combined_ref} } .= $extra;
  return ${ $self->{output_ref} } = $value;
}

1;
