package PDF::Template::Container::Box;

use strict;
use warnings;

use base 'PDF::Template::Container';

sub prerender {
	my ($self, $context) = @_;
	$self->{orig_y} = $context->get($self, 'Y');
}

sub postrender {
	my ($self, $context) = @_;

	my $y = $self->{orig_y};
    my $h = $self->total_of($context, 'H');

	$self->draw_border($context, 100, $y, 100, $h);
}

1;
