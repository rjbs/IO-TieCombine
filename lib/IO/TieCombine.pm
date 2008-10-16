use strict;
use warnings;
package IO::TieCombine;

use Carp ();
use IO::TieCombine::Handle;
use IO::TieCombine::Scalar;
use Symbol ();

sub new {
  my ($class) = @_;

  my $self = {
    combined => \(my $str = ''),
    slots    => { },
  };

  bless $self => $class;
}

sub combined_contents {
  my ($self) = @_;
  return ${ $self->{combined} };
}

sub slot_contents {
  my ($self, $name) = @_;
  Carp::confess("no name provided for slot_contents") unless defined $name;

  Carp::confess("no such output slot exists")
    unless exists $self->{slots}{$name};

  return ${ $self->{slots}{$name} };
}

sub _slot_ref {
  my ($self, $name) = @_;
  Carp::confess("no slot name provided") unless defined $name;

  $self->{slots}{$name} = \(my $str = '') unless $self->{slots}{$name};
  return $self->{slots}{$name};
}

sub _tie_args {
  my ($self, $name) = @_;
  return {
    slot_name    => $name,
    combined_ref => $self->{combined},
    output_ref   => $self->_slot_ref($name),
  };
}
    
sub fh {
  my ($self, $name) = @_;
  my $sym = Symbol::gensym;
  tie *$sym, 'IO::TieCombine::Handle', $self->_tie_args($name);
  return $sym;
}

sub scalar_ref {
  my ($self, $name) = @_;
  tie my $tie, 'IO::TieCombine::Scalar', $self->_tie_args($name);
  return \$tie;
}

sub callback {
  my ($self, $name) = @_;
  my $slot = $self->_slot_ref($name);
  return sub {
    warn ">>@_<<";
    my ($value) = @_;

    ${ $slot             } .= $value;
    ${ $self->{combined} } .= $value;
  }
}

1;
