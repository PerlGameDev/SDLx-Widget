package SDLx::Widget::Particle;
use strict;
use Carp;


sub new {
   my ($class) = @_;
   my $self = bless {}, ref $class || $class;
   return $self;
}

## Offset 
sub x : lvalue {
   $_[0]->{x} = $_[1] if $_[1];
   return shift->{x};
}

sub y : lvalue {
   $_[0]->{y} = $_[1] if $_[1];
   return shift->{y};
}

# Type of particle. This is a Sprite.
sub type : lvalue {
   if (ref $_[1]) 
   {
   	Carp::croak ( ' type must be a SDLx::Widget::Sprite ') unless $_[1]->isa('SDLx::Widget::Sprite');
   	$_[0]->{type} = $_[1];
   }
   return shift->{type};
}

# current frame of animation
sub frame : lvalue {
   $_[0]->{frame} = $_[1] if $_[1];
   return shift->{frame};
}

sub is_dead : lvalue {
   $_[0]->{dead} = 1 if $_[1];
   return shift->{dead};
}


sub show
{
  Carp::croak 'To implement';

}


 

1; #not 42

__END__
=head1 NAME

SDLx::Widget::Particle - Define a particle to use with particle manager

=head1 SYNOPSIS

 use SDLx::Widget::Particle;
 use SDLx::Widget::Sprite;

 my $particle = SDLx::Widget::Particle->new();

 

