package PDF::Template::Container::Box;

use strict;
use warnings;

use base 'PDF::Template::Container';

sub prerender
{
	my ($self, $context) = @_;

	$self->{orig_y} = $context->get($self, 'Y');
	$self->{container_height} = 0;
}

sub postrender {
	my ($self, $context) = @_;

	my $y = $context->get($self, 'Y');
	my $h = $self->{container_height};

	$self->draw_border($context, 100, $y - $h, 100, $h);
}

sub postchild {
	my ($self, $context, $child) = @_;

	$self->{container_height} += $child->deltas($context)->{Y};
}

1;
