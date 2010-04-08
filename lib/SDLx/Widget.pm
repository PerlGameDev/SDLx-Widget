package SDLx::Widget;
use strict;

BEGIN {
    use Exporter ();
    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
    $VERSION     = '0.01';
    @ISA         = qw(Exporter);
    #Give a hoot don't pollute, do not export more than needed by default
    @EXPORT      = qw();
    @EXPORT_OK   = qw();
    %EXPORT_TAGS = ();
}


#################### subroutine header begin ####################

=head2 sample_function

 Usage     : How to use this function/method
 Purpose   : What it does
 Returns   : What it returns
 Argument  : What it wants to know
 Throws    : Exceptions and other anomolies
 Comment   : This is a sample subroutine header.
           : It is polite to include more pod and fewer comments.

See Also   : 

=cut

#################### subroutine header end ####################


sub new
{
    my ($class, %parameters) = @_;

    my $self = bless ({}, ref ($class) || $class);

    return $self;
}


#################### main pod documentation begin ###################
## Below is the stub of documentation for your module. 
## You better edit it!


=head1 NAME

SDLx::Widget - Common Widgets using SDL

=head1 SYNOPSIS

  use SDLx::Widget;
  use SDLx::Widget::Controller;

=head1 DESCRIPTION


=head1 USAGE

Pick a widget connect it to SDLx::Widget::Controller. More to come


=head1 BUGS



=head1 SUPPORT

 #sdl irc.perl.org

=head1 AUTHORS

    Dustin Mays

    Garu
    CPAN ID: GARU

    Zach
    CPAN ID:ZPMORGAN
    
 
    Kartik Thakore
    CPAN ID: KTHAKORE

    http://sdl.perl.org

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

perl(1).

=cut

#################### main pod documentation end ###################


1;
# The preceding line will help the module return a true value

