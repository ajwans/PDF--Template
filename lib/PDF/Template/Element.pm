package PDF::Template::Element;

use strict;
use warnings;

use 5.10.0;

use base 'PDF::Template::Base';

sub set_color
{
    my $self = shift;
    my ($context, $attr, $mode, $depth) = @_;

    my $color = $context->get($self, $attr, $depth);

	my %colormap = (
		black	=> '0,0,0',
		red		=> '255,0,0',
		green	=> '0,255,0',
		blue	=> '0,0,255',
		yellow	=> '255,255,0',
		purple	=> '255,0,255',
		gray	=> '192,192,192',
		white	=> '255,255,255',
	);

	$color = $colormap{$color} if ($color && exists($colormap{$color}));

    return 1 unless $color;

    my @colors = map { $_ / 255 } split /,\s*/, $color, 3;
    $context->{PDF}->color($mode, 'rgb', @colors);

    return 1;
}

# default render does nothing
sub _render
{}

sub render
{
	my ($self, $context) = @_;

    return 0 unless $self->should_render($context);

	$self->prerender($context);
	$self->_render($context);
	$self->postrender($context);

	return 1;
}

sub prerender
{
	my ($self, $context) = @_;

	my ($X, $Y) = map { $context->get($self, $_) } qw/X Y/;

	# allow relative positioning of the cursor
	given ($self->{Y}) {
		when (undef) {
		}

		when (m/^-(\d+)/) {
			$Y -= $1;
		}

		when (m/^[+](\d+)/) {
			$Y += $1;
		}

		default {
			$Y = $self->{Y};
		}
	}

	# save for later in case this element should not move the cursor
	map { $self->{'OLD_' . $_} = $_ } qw/X Y/;

    my $p = $context->{PDF};
	$p->move($X, $Y);
	@{$context}{qw/X Y/} = ($X, $Y);

	warn "\t" x $context->{LEVEL} . "rendering $self->{TAG} at $X,$Y"
		if $context->{DEBUG};
}

sub postrender
{
	my ($self, $context) = @_;
	my $reset_cursor = $self->{RESET_CURSOR};

	# reset the X/Y coordinates if no_translate attribute is set
	if ($reset_cursor) {
		warn "reset cursor set, resetting coords" if $context->{DEBUG};
		@{$context}{qw/X Y/} = @{$self}{qw/OLD_X OLD_Y/};
	}
}

1;
__END__

=head1 NAME

PDF::Template::Element

=head1 PURPOSE

To provide a base class for all rendering nodes.

=head1 COLORS

This is the class that handles colors. Colors in PDF::Template are specified in
RGB format, comma-separated. Each number is from 0 to 255, with 0 being none and
255 being most. If a color is not specified, 0 is assumed. Thus, "255,0,0",
"255,0", and "255" will all result in a red color.

Colors should be used for all attributes that have the word "COLOR" in the name.
This includes (but may not be limited to):

=over 4

=item * COLOR

=item * FILLCOLOR

=back

=head1 SEE ALSO

=cut
