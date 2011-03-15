package PDF::Template::Container;

use strict;

BEGIN {
    use vars qw(@ISA);
    @ISA = qw(PDF::Template::Base);

    use PDF::Template::Base;
}

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
#{
#    my $self = shift;
#    my ($context) = @_;
#
#    for my $e (@{$self->{ELEMENTS}})
#    {
#        $e->enter_scope($context);
#        $e->begin_page($context);
#        $e->exit_scope($context, 1);
#    }
#
#    return 1;
#}

sub end_page { _do_page @_, 'end_page' }
#{
#    my $self = shift;
#    my ($context) = @_;
#
#    for my $e (@{$self->{ELEMENTS}})
#    {
#        $e->enter_scope($context);
#        $e->end_page($context);
#        $e->exit_scope($context, 1);
#    }
#
#    return 1;
#}

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

	if ($context->{DEBUG}) {
		warn "rendering " . ref($self) . " at " . $context->{X} . ", " .
			$context->{Y} . "\n";
		warn "rendered items\n\t" . join("\n\t", map { ref($_) }
					grep { $_->has_rendered() } @{$self->{ELEMENTS}}) . "\n";
		warn "unrendered items\n\t" . join("\n\t", map { ref($_) }
					grep { !$_->has_rendered() } @{$self->{ELEMENTS}}) . "\n";
	}

    for my $e (grep !$_->has_rendered, @{$self->{ELEMENTS}})
    {
        $e->enter_scope($context);

        my $rc;
		warn "\trendering " . ref($e) . " at " . $context->{X} . ", " .
			$context->{Y} . "\n" if $context->{DEBUG};
        if ($rc = $e->render($context))
        {
			warn "\trendered " . ref($e) . "\n" if $context->{DEBUG};
            $e->mark_as_rendered;
        }
		warn "\tresult $rc\n" if $context->{DEBUG};
        $continue = $rc if $continue;

        $e->exit_scope($context);

		last if (!$continue && $context->pagebreak_tripped());
    }

	if ($context->{DEBUG}) {
		warn "rendered /" . ref($self) . " result $continue\n";
	}

    return $continue;
}

sub render
{
    my $self = shift;
    my ($context) = @_;

    return 0 unless $self->should_render($context);

    return $self->iterate_over_children($context);
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
