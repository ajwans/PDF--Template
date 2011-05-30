package PDF::Template;

use strict;
use warnings;

our $VERSION = 0.06;
our @ISA;

sub import {
	my ($class, %opts) = @_;
	no strict 'refs';

	# Sub in the correct API
	if ($opts{personality} && $opts{personality} eq 'PDF::Writer') {
		require PDF::Template::WriterAPI;
		PDF::Template::WriterAPI->import();
		@ISA = ('PDF::Template::WriterAPI');
	} else {
		require PDF::Template::OldAPI;
		PDF::Template::OldAPI->import();
		@ISA = ('PDF::Template::OldAPI');
	}
}

1;
