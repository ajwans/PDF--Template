package PDF::Template::Element;

use strict;
use warnings;

use 5.10.0;

use base 'PDF::Template::Base';

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
	warn ' ' x $context->{LEVEL} . "rendering $self->{TAG} at $X,$Y\n"
		if $context->{DEBUG};
}

sub postrender
{
	my ($self, $context) = @_;

	my ($X, $Y) = map { $context->get($self, $_) } qw/X Y/;
	warn ' ' x $context->{LEVEL} . "rendered / $self->{TAG} to $X,$Y\n"
		if $context->{DEBUG};
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
