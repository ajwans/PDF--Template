package PDF::Template::Container::Debug;

use strict;
use warnings;

use base 'PDF::Template::Container';

sub new
{
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    return $self;
}

sub enter_scope
{
    my $self = shift;
    my ($context) = @_;

	$context->{DEBUG}++;

    $self->SUPER::enter_scope($context);

	return 1;
}

sub exit_scope
{
    my $self = shift;
    my ($context) = @_;

	$context->{DEBUG}--;

    return $self->SUPER::exit_scope($context);
}

1;

__END__

=head1 NAME

PDF::Template::Container::Debug

=head1 PURPOSE

Output debugging information when placing the enclosed elements

=head1 NODE NAME

DEBUG

=head1 INHERITANCE

PDF::Template::Container

=head1 ATTRIBUTES

None

=head1 CHILDREN

None

=head1 AFFECTS

STDOUT

=head1 DEPENDENCIES

None

=head1 USAGE

  <debug>...</debug>

That produces debugging output for the elements between
the debug tags.

=head1 AUTHOR

Andrew Wansink (andy@halogix.com)

=head1 SEE ALSO

=cut
