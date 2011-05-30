package PDF::Template::Base;

use strict;
use warnings;

use PDF::Template::Constants qw(
    %Verify
);

use PDF::Template::Factory;
use List::Util qw/min/;

sub new
{
    my $class = shift;

    push @_, %{shift @_} while UNIVERSAL::isa($_[0], 'HASH');
    (@_ % 2) && die "$class->new() called with odd number of option parameters", $/;

    my %x = @_;

    # Do not use a hashref-slice here because of the uppercase'ing
    my $self = {};
    $self->{uc $_} = $x{$_} for keys %x;

    $self->{__THIS_HAS_RENDERED__} = 0;

    bless $self, $class;
}

sub isa { PDF::Template::Factory::isa(@_) }

# These functions are used in the P::T::Container & P::T::Element hierarchies

sub _validate_option
{
    my $self = shift;
    my ($option, $val_ref) = @_;

    $option = uc $option;
    return 1 unless exists $Verify{$option} && UNIVERSAL::isa($Verify{$option}, 'HASH');

    if (defined $val_ref)
    {
        if (!defined $$val_ref)
        {
            $$val_ref = $Verify{$option}{'__DEFAULT__'};
        }
        elsif (!exists $Verify{$option}{$$val_ref})
        {
            my $name = ucfirst lc $option;
            warn "$name '$$val_ref' unsupported. Defaulting to '$Verify{$option}{'__DEFAULT__'}'", $/;
            $$val_ref = $Verify{$option}{'__DEFAULT__'};
        }
    }
    elsif (!defined $self->{$option})
    {
        $self->{$option} = $Verify{$option}{'__DEFAULT__'};
    }
    elsif (!exists $Verify{$option}{$self->{$option}})
    {
        my $name = ucfirst lc $option;
        warn "$name '$self->{$option}' unsupported. Defaulting to '$Verify{$option}{'__DEFAULT__'}'", $/;
        $self->{$option} = $Verify{$option}{'__DEFAULT__'};
    }

    return 1;
}

sub calculate { ($_[1])->get(@_[0,2]) }
#{
#    my $self = shift;
#    my ($context, $attr) = @_;
#
#    return $context->get($self, $attr);
#}

sub enter_scope { ($_[1])->enter_scope($_[0]) }
#{
#    my $self = shift;
#    my ($context) = @_;
#
#    return $context->enter_scope($self);
#}

sub exit_scope { ($_[1])->exit_scope(@_[0, 2]) }
#{
#    my $self = shift;
#    my ($context, $no_delta) = @_;
#
#    return $context->exit_scope($self, $no_delta);
#}

sub deltas
{
#    my $self = shift;
#    my ($context) = @_;

    return {};
}

sub reset            { $_[0]{__THIS_HAS_RENDERED__} = 0 }
sub mark_as_rendered { $_[0]{__THIS_HAS_RENDERED__} = 1 }
sub has_rendered     { $_[0]{__THIS_HAS_RENDERED__} }
sub should_render    { ($_[0]{__THIS_HAS_RENDERED__}) || (($_[1])->should_render($_[0])) }

sub resolve
{
#    my $self = shift;
#    my ($context) = @_;

    '';
}

sub render
{
    my $self = shift;
    my ($context) = @_;

	warn "\t\tXrendering $self->{NAME}" if $context->{DEBUG};

    return 1;
}

sub begin_page
{
#    my $self = shift;
#    my ($context) = @_;

    return 1;
}

sub end_page
{
#    my $self = shift;
#    my ($context) = @_;

    return 1;
}

# draw a border
# 
# x,y         x+w,y
# |------------|
# |            |
# |            |
# |            |
# |            |
# |------------|
# x,y-h			x+w,y-h

sub draw_border
{
	my ($self, $context, $x, $y, $width, $height) = @_;

    my $p = $context->{PDF};
    $p->save_state();

	my $border = $context->get($self, 'BORDER');
    if ($border) {
		$p->linewidth($border);

		if ($context->get($self, 'BORDER_COLOR')) {
			$self->set_color($context, 'BORDER_COLOR', 'stroke');
		}

		my $radius = $context->get($self, 'RADIUS');
		if ($radius) {
			use constant SIN_45 => 0.707;

			# radius can't be more than half the height
			$radius = min($radius, abs($height) / 2);

			my $shorten = $radius * SIN_45;

			# left side
			$p->move($x, $y - $shorten);
			$p->line($x, $y - $height + $shorten);

			# arc the bottom left corner
			$p->arc($x + $shorten, $y - $height + $shorten, $shorten, $shorten,
																180, 270);

			# bottom line
			$p->line($x + $width - $shorten, $y - $height);

			# arc the top right corner
			$p->arc($x + $width - $shorten, $y - $height + $shorten, $shorten,
														$shorten, -90, 0);

			# right side
			$p->line($x + $width, $y - $shorten);

			# arc the top right corner
			$p->arc($x + $width - $shorten, $y - $shorten, $shorten, $shorten,
																	0, 90);

			# top line
			$p->line($x + $shorten, $y);

			# arc the top left corner
			$p->arc($x + $shorten, $y - $shorten, $shorten, $shorten, 90, 180);
		} else {
			$p->rect($x, $y, $width, -$height);
		}

		if ($context->get($self, 'BGCOLOR')) {
				$self->set_color($context, 'BGCOLOR', 'fill');
				$p->fill_stroke();
		} else {
				$p->stroke();
		}
    }

    $p->restore_state();
}

sub set_color
{
    my $self = shift;
    my ($context, $attr, $mode, $depth) = @_;

    my $color = $context->get($self, $attr, $depth);

	my %colormap = (
		black	=> '0,0,0',
		red		=> '255,0,0',
		green	=> '0,255,0',
		blue	=> '0,0,255',
		yellow	=> '255,255,0',
		purple	=> '255,0,255',
		gray	=> '192,192,192',
		white	=> '255,255,255',
	);

	$color = $colormap{$color} if ($color && exists($colormap{$color}));

    return 1 unless $color;

    my @colors = map { $_ / 255 } split /,\s*/, $color, 3;
    $context->{PDF}->color($mode, 'rgb', @colors);

    return 1;
}

1;
__END__
