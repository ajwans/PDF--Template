package PDF::Template::Element::Pos;

use strict;
use warnings;

use 5.10.0;

use base 'PDF::Template::Element';

sub new
{
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    return $self;
}

1;
__END__

=head1 NAME

PDF::Template::Element::Pos

=head1 PURPOSE

Move the cursor to a new position

=head1 NODE NAME

POS

=head1 INHERITANCE

PDF::Template::Element

=head1 ATTRIBUTES

=over 1

=item * Y
The new Y position, either absolute or +/- to make a relative move

=back

=head1 CHILDREN

None

=head1 AFFECTS

Resultant PDF

=head1 DEPENDENCIES

None

=head1 USAGE

  <pos y="-10"/>

That moves the cursor form its current position down the page 10 points.

=head1 AUTHOR

Andrew Wansink (andy@halogix.com)

=head1 SEE ALSO

=cut
