package PDF::Template::Element::Pos;

use strict;

BEGIN {
    use vars qw(@ISA);
    @ISA = qw(PDF::Template::Base);

    use PDF::Template::Base;
}

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
