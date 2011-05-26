package PDF::Template::Container::Box;

use strict;
use warnings;

use base 'PDF::Template::Container';

sub postrender {
	my ($self, $context) = @_;

	my $y = $context->get($self, 'Y');
    my $h = $self->total_of($context, 'H');

	$self->draw_border($context, 100, $y, 100, $h);
}

sub postchild {
	my ($self, $context, $child) = @_;

	# if there's a page break push it onto a list so that we can generate
	# borders around cross page sections
}

1;
