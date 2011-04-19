#!/usr/bin/perl

use warnings;
use strict;
use utf8;

use SDL;
use SDL::Event;
use SDL::Rect;
use SDLx::App;
use SDLx::Surface;
use SDL::Color;

use lib qw(lib ../lib);
use SDLx::Widget::Button;

# Create App
my $app = SDLx::App->new(width => 800, height => 800 );

# Create button surface
my $surface = SDLx::Surface->new(width => 6*100, height => 600);

# For example fill bsurface and make sequences for animation. We create gradient
# of 10 steps. Gradient sets horizontally. In vertical we have button state. You
# can see example in the bottom of screen.
my $color_from = 128;
my %sequences;
for(my $i = 0; $i < 6; $i ++ )
{
    my $color = $color_from + $i * 8;
    $surface->draw_rect([100 * $i,0,  100,100], SDL::Color->new($color, 0, 0));
    $surface->draw_rect([100 * $i,100,100,100], SDL::Color->new(0, $color, 0));
    $surface->draw_rect([100 * $i,200,100,100], SDL::Color->new(0, 0, $color));
    $surface->draw_rect([100 * $i,300,100,100], SDL::Color->new($color, 0, $color));
    $surface->draw_rect([100 * $i,400,100,100], SDL::Color->new($color, $color, $color));
    $surface->draw_rect([100 * $i,500,100,100], 0x666666FF);

    push @{$sequences{over}},   [100 * $i,   0];
    push @{$sequences{out}},    [100 * $i, 100];
    push @{$sequences{down}},   [100 * $i, 200];
    push @{$sequences{up}},     [100 * $i, 300];
    push @{$sequences{d_over}}, [100 * $i, 400];
    push @{$sequences{d_out}},  [100 * $i, 500];
}

# Create button
my $button = SDLx::Widget::Button->new(
    surface     => $surface,
    step_x      => 1,
    step_y      => 1,
    sequences   => \%sequences,
    rect        => SDL::Rect->new(0,0,100,100),
    ticks_per_frame => 4,
    type        => 'reverse',

    disable     => 0,
    app         => $app,
    parent      => $app,

    text        => SDLx::Text->new(
        font    => '/usr/share/fonts/truetype/freefont/FreeSans.ttf',
        size    => 24,
        color   => 0xFFFFFFFF,
        mode    => 'utf8',
        h_align => 'left',
        text    => 'out',
    ),
    # Callback change tet on button as current button state
    cb          => sub {
        my ($self, $state) = @_;
        $self->text->text( $state );

        if($state eq 'up')
        {
            ;
        }
    }
);
# Start animation
$button->start;
# Show button
$button->show;

# Add standart application handlers and run application
$app->add_event_handler( sub{
    my ($event, $application) = @_;
    $surface->blit($app, undef, [0, 150, 640, 280]);
    exit if $event->type eq SDL_QUIT;
});
$app->add_show_handler( sub{
    my ($delta, $application) = @_;
    $app->flip;
});
$app->run;
