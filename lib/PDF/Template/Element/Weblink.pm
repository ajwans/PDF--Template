package PDF::Template::Element::Weblink;

use strict;
use warnings;

use base 'PDF::Template::Element';

sub new
{
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    $self->{TXTOBJ} = PDF::Template::Factory->create('TEXTOBJECT');

    return $self;
}

sub _render
{
    my $self = shift;
    my ($context) = @_;

    return 1 if $context->{CALC_LAST_PAGE};

    my $url = $context->get($self, 'URL');

    unless (defined $url)
    {
        warn "Weblink: no URL defined!", $/;
        return 1;
    }

    my $txt = $self->{TXTOBJ}->resolve($context);

    my @dimensions = map {
        $context->get($self, $_) || 0
    } qw( X1 Y1 X2 Y2 );

	my $x = $context->get($self, 'X') || $context->{X};
	my $y = $context->get($self, 'Y') || $context->{Y};

	my ($x2, $y2) = $context->{PDF}->show_xy($txt, $x, $y);
    $context->{PDF}->add_weblink( $x, $y, $x2, $y2, $url);

    return 1;
}

1;
__END__

=head1 NAME

PDF::Template::Element::WebLink

=head1 PURPOSE

To provide a clickable web-link

=head1 NODE NAME

WEBLINK

=head1 INHERITANCE

PDF::Template::Element

=head1 ATTRIBUTES

=over 4

=item * URL
The URL to go to, when clicked

=item * X1 / X2 / Y1 / Y2

The dimensions of the clickable area

=back

=head1 CHILDREN

None

=head1 AFFECTS

Nothing

=head1 DEPENDENCIES

None

=head1 USAGE

This node is currently under review as to whether it should be removed and a
URL attribute should be added to various nodes, such as IMAGE, TEXTBOX, and ROW.

=head2 USE AT YOUR OWN RISK

=head1 AUTHOR

Rob Kinyon (rkinyon@columbus.rr.com)

=head1 SEE ALSO

=cut
