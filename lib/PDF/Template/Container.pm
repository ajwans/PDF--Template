package PDF::Template::Container;

use strict;
use warnings;

use base 'PDF::Template::Base';

# Containers are objects that can contain arbitrary elements, such as
# PageDefs or Loops.

sub new
{
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    $self->{ELEMENTS} = [] unless UNIVERSAL::isa($self->{ELEMENTS}, 'ARRAY');

    return $self;
}

sub _do_page
{
    my $self = shift;
    my ($context, $method) = @_;

    for my $e (@{$self->{ELEMENTS}})
    {
        $e->enter_scope($context);
        $e->$method($context);
        $e->exit_scope($context, 1);
    }

    return 1;
}

sub begin_page { _do_page @_, 'begin_page' }

sub end_page { _do_page @_, 'end_page' }

sub reset
{
    my $self = shift;

    $self->SUPER::reset;
    $_->reset for @{$self->{ELEMENTS}};
}

sub iterate_over_children
{
    my $self = shift;
    my ($context) = @_;

    my $continue = 1;

	warn ' ' x $context->{LEVEL} .
			"rendering container $self->{TAG} at $context->{X},$context->{Y}\n"
		if ($context->{DEBUG});

	$context->{LEVEL}++;

    for my $e (grep !$_->has_rendered, @{$self->{ELEMENTS}})
    {
        $e->enter_scope($context);

        my $rc = $e->render($context);
        if ($rc) {
            $e->mark_as_rendered;
        }
        $continue = $rc if $continue;

		# no deltas for containers
        $e->exit_scope($context, $e->isa('PDF::Template::Container') ? 1 : 0);

		warn ' ' x $context->{LEVEL} . "context Y now " . $context->{Y}
			if ($context->{DEBUG});

		last if (!$continue && $context->pagebreak_tripped());
    }

	$context->{LEVEL}--;

	warn ' ' x $context->{LEVEL} . 'rendered container /' . $self->{TAG} .
		" result $continue\n" if ($context->{DEBUG});

    return $continue;
}

sub prerender {}

sub postrender {}

sub render
{
    my $self = shift;
    my ($context) = @_;

    return 0 unless $self->should_render($context);

	$self->prerender($context);

	my $ret = $self->iterate_over_children($context);

	$self->postrender($context);

	return $ret;
}

sub max_of
{
    my $self = shift;
    my ($context, $attr) = @_;

    my $max = $context->get($self, $attr);

    ELEMENT:
    foreach my $e (@{$self->{ELEMENTS}})
    {
        $e->enter_scope($context);

        my $v = $e->isa('CONTAINER')
            ? $e->max_of($context, $attr)
            : $e->calculate($context, $attr);

        $max = $v if $max < $v;

        $e->exit_scope($context, 1);
    }

    return $max;
}

sub total_of
{
    my $self = shift;
    my ($context, $attr) = @_;

    my $total = 0;

    ELEMENT:
    foreach my $e (@{$self->{ELEMENTS}})
    {
        $e->enter_scope($context);

        $total += $e->isa('CONTAINER')
            ? $e->total_of($context, $attr)
            : $e->calculate($context, $attr);

        $e->exit_scope($context, 1);
    }

    return $total;
}

1;
__END__
