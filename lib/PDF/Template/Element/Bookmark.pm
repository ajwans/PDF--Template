package PDF::Template::Element::Bookmark;

use strict;

BEGIN {
    use vars qw(@ISA);
    @ISA = qw(PDF::Template::Element);

    use PDF::Template::Element;
}

sub new
{
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    $self->{TXTOBJ} = PDF::Template::Factory->create('TEXTOBJECT');

    return $self;
}

sub render
{
    my $self = shift;
    my ($context) = @_;

    return 0 unless $self->should_render($context);

    return 1 if $context->{CALC_LAST_PAGE};

    my $txt = $self->{TXTOBJ}->resolve($context);

    unless (defined $txt)
    {
        warn "Bookmark: no text defined!", $/;
        $txt = 'undefined';
    }

	my $opts = $self->{PARENT} ?
					'parent=' . $context->{BOOKMARKS}->{$self->{PARENT}} : '';

    my $bookmark_id = $context->{PDF}->add_bookmark($txt, $opts, 0);

	if ($self->{NAME}) {
		$context->{BOOKMARKS}->{$self->{NAME}} = $bookmark_id;
	}

    return 1;
}

1;
__END__

=head1 NAME

PDF::Template::Element::Bookmark

=head1 PURPOSE

Creates a bookmark in the resultant PDF.

=head1 NODE NAME

BOOKMARK

=head1 INHERITANCE

PDF::Template::Element

=head1 ATTRIBUTES

None

=head1 CHILDREN

Text and &lt;VAR&gt; nodes. The text contained will be the location of the
bookmark.

=head1 AFFECTS

Resultant PDF

=head1 DEPENDENCIES

None

=head1 USAGE

  <bookmark text="Some Bookmark"/>

That now adds a bookmark for that spot to the PDF, called "Some Bookmark".

=head1 AUTHOR

Rob Kinyon (rkinyon@columbus.rr.com)

=head1 SEE ALSO

=cut
