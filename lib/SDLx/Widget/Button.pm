use strict;
use warnings;
use utf8;

package SDLx::Widget::Button;
use base qw(SDLx::Sprite::Animated);

use Carp;

use SDL;
use SDL::Event;
use SDL::Events;
use SDL::Rect;
use SDLx::App;
use SDLx::Text;

=head1 NAME

Game::TD::Model::Button - Simple rectangle button

=head1 SYNOPSIS

    use SDLx::Widget::Button;

    # Create application
    $app = SDLx::App->new;

    # Create button from image file.
    my $button = SDLx::Widget::Button->new(
        # Similarly SDLx::Sprite::Animated
        image       => 'button.png',
        step_x      => 1,
        step_y      => 1,
        sequences   => {
            over    => [[0,0]],
            out     => [[100,0]],
            down    => [[200,0]],
            up      => [[300,0]],
            d_over  => [[400,0]],
            d_out   => [[500,0]],
        },
        rect        => SDL::Rect->new(0,0,100,100),

        # Set application. All handlers will be automatical add in application.
        app         => $app,
        # Button disabled (by default button enabled)
        disable     => 1,
        # Set some text on button (optional)
        text        => SDLx::Text->new(...),
        # Make some job on click
        cb          => sub {
            my ($self, $state) = @_;
            if($sequence eq 'up') { ... }
        }
    );

    # Run application
    $app->run;

=head1 DESCRIPTION

This is simple rectangle button to use in SDL application. SDLx::Widget::Button
based on SDLx::Sprite::Animated package and take all of it`s methods and
options.

You need to set named sequence for each button state for draw:
over - mouse corsor outside the button,
out  - mouse cirsor on button,
down - left "mouse button" pressed on button,
up   - left "mouse button" unpressed on button.
Sequence d_over and d_out is optional. If you want disable/enable button then
this sequences.

=cut

=head1 METHODS

=cut

=head2 new %opts

This constrictor take options from SDLx::Sprite::Animated, except:

=over

=item app

SDLx::App object to add handlers for draw and event

=item cb

Callback function called on button state change

=item parent

This is SDLx::App or SDLx::Surface to draw button on it.

=item prect

Coordinates SDL::Rect of parent surface. Set it if parent surface has offset.

=item disable

Flag to disable button. Disabled button has it`s own sequences for draw and not
react on mouse button click.

=item text

If you wish to draw txt on button, just create SDLx::Text object and set this
option.

=back

=cut

sub new
{
    my ($class, %opts) = @_;

    # Main opts
    my $app     = delete $opts{app};
    my $cb      = delete $opts{cb}      // sub{};
    my $parent  = delete $opts{parent}  // $app;
    my $prect   = delete $opts{prect}   // SDL::Rect->new(0,0,0,0);
    my $disable = delete $opts{disable} // 0;
    # Text opts
    my $text    = delete $opts{text};

    confess 'Missing app parameter. Must be SDLx::App' unless defined $app;
    confess 'Missing parent parameter. Must be SDLx::App or SDLx::Surface'
        unless defined $parent;

    my $self = $class->SUPER::new(%opts);

    $self->{callback} = $cb;

    $self->app( $app );
    $self->parent( $parent );
    $self->prect( $prect );
    $self->disable( $disable );
    $self->text( $text ) if $text;

    $self->sequence( ($self->disable) ?'d_out' :'out' );

    return $self;
}

=head2 app $app

Get or set $app SDLx::App object.

=cut

sub app
{
    my ($self, $app) = @_;
    $self->{app} = $app if defined $app;
    return $self->{app};
}

=head2 show

Invoke this method after create button to add event and show handlers in app.

=cut

sub show
{
    my $self = shift;

    $self->app->add_event_handler(sub {
        my ($event, $app) = @_;
        $self->event_handler($event);
    });

    $self->app->add_show_handler(sub {
        my ($delta, $app) = @_;
        $self->draw_handler;
    });
}

=head2 event_handler $event

Event handler. Update button sequence on user $event (SDL::Event object):
move mouse, click buttons.

=cut

sub event_handler
{
    my ($self, $event) = @_;

    my $type        = $event->type;
    my $sequence    = $self->sequence;
    my $prev        = $sequence;

    if($type == SDL_MOUSEMOTION)
    {
        if( $self->is_over($event->motion_x, $event->motion_y) )
        {
            $sequence = 'over' unless $sequence eq 'down';
        }
        else
        {
            $sequence = 'out';
        }
    }
    elsif($type == SDL_MOUSEBUTTONDOWN && ! $self->disable)
    {
        if( $event->button_button == SDL_BUTTON_LEFT )
        {
            $sequence = 'down'
                if $self->is_over($event->button_x, $event->button_y);
        }
    }
    elsif($type == SDL_MOUSEBUTTONUP && ! $self->disable)
    {
        # Check 'down' for prevent press from another state
        if($sequence eq 'down')
        {
            if( $event->button_button == SDL_BUTTON_LEFT )
            {
                $sequence = 'up'
                    if $self->is_over($event->button_x, $event->button_y);
            }
        }
    }

    if( $prev ne $sequence )
    {
        # Update sequence if state changed
        $self->sequence( ($self->disable) ?"d_$sequence" :$sequence );
        $self->{callback}->($self, $sequence);
    }

    return;
}

=head2 draw_handler $surface

Draw button on $surface. By default $surface gets from parent.

=cut

sub draw_handler
{
    my ($self, $surface) = @_;

#    use Data::Dumper;
#    die Dumper $surface, $self->parent;

    $self->draw($surface // $self->parent);

    $self->text->write_xy(
        $surface // $self->parent,
        $self->rect->x,
        $self->rect->y)
            if $self->text;

    return;
}

=head2 is_over $x, $y

Check if $x and $y coordinates within button rect

=cut

sub is_over
{
    my ($self, $x, $y) = @_;

    my ($dx, $dy) = ($self->prect->x, $self->prect->y);

    return 1 if
        $x >= $dx + $self->rect->x                  &&
        $x <  $dx + $self->rect->x + $self->rect->w &&
        $y >= $dy + $self->rect->y                  &&
        $y <  $dy + $self->rect->y + $self->rect->h;

    return 0;
}

=head2 parent $parent

Get or set $parent surface.

=cut

sub parent
{
    my ($self, $parent) = @_;
    $self->{parent} = $parent if defined $parent;
    return $self->{parent};
}

=head2 prect $rect

Get or set offset $rect of parent surface. Use it if parent surface has offset.
This rect not effec how to draw button, but react on mouse will wrong.

=cut

sub prect
{
    my ($self, $rect) = @_;
    $self->{prect} = $rect if defined $rect;
    return $self->{prect};
}

=head2 disable $disable

Disable or enable button by $disable bool flag. Remember: you need d_over and
d_out sequences to correct draw disabled button.

=cut

sub disable
{
    my ($self, $disable) = @_;
    $self->{disable} = ($disable) ?1 :0 if defined $disable;
    return $self->{disable};
}

=head2 text $text

Get or set $text for button. This is SDLx::Text object.

=cut

sub text
{
    my ($self, $text) = @_;
    $self->{text} = $text if defined $text;
    return $self->{text};
}

1;
__END__

=head1 BUGS AND LIMITATIONS

=over 4

=item * SDLx::Text align work not correct

=back

=head1 AUTHORS

Roman V. Nikolaev C<< <rshadow@rambler.ru> >>

=head1 SEE ALSO

L<< SDLx::App >>, L<< SDLx::Controller >>, L<< SDLx::Text >>,
L<< SDLx::Widget >>