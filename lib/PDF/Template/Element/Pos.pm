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

sub render
{
    my $self = shift;
    my ($context) = @_;

	$context->{Y} = $self->{Y};
}

1;
__END__
