package SDLx::Widget;
use strict;

BEGIN {
    use Exporter ();
    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
    $VERSION     = '0.02';
    @ISA         = qw(Exporter);
    #Give a hoot don't pollute, do not export more than needed by default
    @EXPORT      = qw();
    @EXPORT_OK   = qw();
    %EXPORT_TAGS = ();
}


=head1 NAME

SDLx::Widget - Common Widgets using SDL

=head1 SYNOPSIS

  use SDLx::Widget;
  use SDLx::Widget::Controller;

=head1 DESCRIPTION


=head1 USAGE

Pick a widget connect it to SDLx::Widget::Controller. More to come

See the examples directory that came with this package

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

