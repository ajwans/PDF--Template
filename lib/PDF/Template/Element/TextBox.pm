package PDF::Template::Element::TextBox;

use strict;
use warnings;

use base 'PDF::Template::Element';

use Encode;

use Carp qw/cluck carp/;
use Data::Dumper;
use List::Util qw/min/;

sub new
{
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    $self->{TXTOBJ} = PDF::Template::Factory->create('TEXTOBJECT');

    return $self;
}

sub get_text
{
    my $self = shift;
    my ($context) = @_;

    my $txt = $context->get($self, 'TEXT');
    if (defined $txt)
    {
        my $txt_obj = PDF::Template::Factory->create('TEXTOBJECT');
        push @{$txt_obj->{STACK}}, $txt;
        $txt = $txt_obj->resolve($context);
    }
    elsif ($self->{TXTOBJ})
    {
        $txt = $self->{TXTOBJ}->resolve($context)
    }
    else
    {
#       $txt = Unicode::String::utf8('');
        $txt = '';
    }

    return $txt;
}

sub _render
{
    my $self = shift;
    my ($context) = @_;

    delete $self->{TEMP_H} if exists $self->{TEMP_H};

    if ($context->{CALC_LAST_PAGE})
    {
        $self->{TEMP_H} = $self->calculate($context, 'H');
        return 1;
    }

    my $x = $context->get($self, 'X');
    my $y = $context->get($self, 'Y');
    my $w = $context->get($self, 'W');

	# if W is not specified then use the remaining space on the page
	if (!defined($w)) {
		$w = $context->get($self, 'PAGE_WIDTH') -
									$context->get($self, 'RIGHT_MARGIN') - $x;
		$context->{W} = $w;
	}

    my $h = $context->get($self, 'H');

    my $align = $context->get($self, 'ALIGN') ||
                $context->get($self, 'JUSTIFY');

    $self->_validate_option('ALIGN', \$align);

    $self->set_color($context, 'COLOR', 'both');

    my ($orig_x, $orig_w, $orig_y) = ($x, $w, $y);

    if (defined(my $lmargin = $context->get($self, 'LMARGIN')))
    {
        $x += $lmargin;
        $w -= $lmargin;
    }

    if (defined(my $rmargin = $context->get($self, 'RMARGIN')))
    {
        $w -= $rmargin;
    }

    my $txt = $self->get_text($context);

	warn ' ' x $context->{LEVEL} .
				"putting text '$txt' at X,Y,W,H => $x,$y,$w,$h\n"
		if ($context->{DEBUG});

	$self->{TEMP_H} = $self->calculate($context, 'H');

	my $valign = $context->get($self, 'VALIGN');
	if (defined($valign) && $valign eq 'center') {
		my $font_size = $context->{PDF}->font_size;
		$y = ($y + $y - $h + $font_size) / 2;
	}

	if ($context->get($self, 'TEXT_COLOR')) {
		$self->set_color($context, 'TEXT_COLOR', 'fill');
	}
    $self->show_boxed($context, $txt, $x, $y, $w, $h, $align, '');
	$y = $orig_y;

	if ($context->{DEBUG}) {
		warn ' ' x $context->{LEVEL} . "calc h " . $self->{TEMP_H} . "\n";
	}

	$self->draw_border($context, $orig_x, $y, $orig_w, $h);

    return 1;
}

sub deltas
{
    my $self = shift;
    my ($context) = @_;

	my $x	= $context->get($self, 'X');
	my $dx	= $context->get($self, 'W') ||
									$context->get($self, 'PAGE_WIDTH') - $x -
									$context->get($self, 'RIGHT_MARGIN');

    return {
        X => $dx,
        Y => -$self->{TEMP_H},
    };
}

sub _display_doublebyte
{
    my $self = shift;
    my ($p, $str, $x, $y, $j, $font_size) = @_;

    if ($j eq 'right')
    {
        $x -= length($str) * $font_size;
    }
    elsif ($j eq 'center')
    {
        $x -= (length($str) / 2) * $font_size;
    }

    $p->show_xy($str, $x, $y);

    return 0;
}

sub _show_boxed
{
    my $self = shift;
    my $context = shift;

    my $encoding = $context->get($self, 'PDF_ENCODING') || 'host';

    if (my $text_encoding = $context->get($self, 'TEXT_ENCODING'))
    {
        require Encode::compat if $] <= 5.008;
        require Encode;
        unshift @_, Encode::decode($text_encoding => shift(@_))
          unless Encode::is_utf8($_[0]);
    }

    unless ( Encode::is_utf8($_[0]) ) {
        my $str = shift;
        my $leftovers = $context->{PDF}->show_boxed($str, @_);

        $leftovers++ if $leftovers && $leftovers == length($str) - 1;
        return $leftovers;
    }

    my ($p, $str, $x, $y, $w, $h, $j, $m) = ($context->{PDF}, @_);

    my $font_size = $p->font_size;
    die "Fontsize of 0!", $/ if $font_size <= 0;

    if ($w == 0 && $h == 0)
    {
        return 0 if $m eq 'blind';
        return $self->_display_doublebyte($p, $str, $x, $y, $j, $font_size);
    }

    my $num_lines = int($h / $font_size);
    my $chars_per_line = int($w / $font_size) * 2;

    my $right = $x + $w;
    my $mid    = int(($x + $right) / 2);

    my $current_y = $y - $font_size;

    foreach my $line_num (0 .. $num_lines - 1)
    {
        my $start_x = $x;
        $start_x = $right if $j eq 'right';
        $start_x = $mid if $j eq 'center';

        if (length($str) <= $chars_per_line)
        {
            return 0 if $m eq 'blind';
            return $self->_display_doublebyte($p, $str, $start_x, $current_y,
															$j, $font_size);
        }

        my $str_this_line = substr($str, 0, $chars_per_line);

        $self->_display_doublebyte($p, $str_this_line, $start_x, $current_y,
															$j, $font_size)
            unless $m eq 'blind';

        $current_y -= $font_size;
        $str = substr($str, $chars_per_line);
    }

    return length($str);
}

sub show_boxed
{
    my $self = shift;
	my $context = shift;
    my ($str, $x, $y, $w, $h, $align, $mode) = @_;

    my $fsize = $context->{PDF}->font_size;
    $fsize = 0 if $fsize < 0;

#   return $h unless $str->length && ($fsize && $h / $fsize >= 1);
	return $h unless length($str) && ($fsize && $h / $fsize >= 1);

    my $total_h = $h;
#   my $excess_txt = Unicode::String::utf8('');
    my $excess_txt = '';

    LOOP:
    {
        my $leftovers = $self->_show_boxed(
            $context, $str,
            $x, $y, $w, $h,
            $align, $mode,
        );
        die "Invalid return ($leftovers) from _show_boxed() on string '$str'", $/
            if $leftovers > length($str);

        last LOOP if $context->get($self, 'TRUNCATE_TEXT');

        if ($leftovers < length($str))
        {
            last LOOP unless $excess_txt || $leftovers;

            $str = ($leftovers ? substr($str, -1 * $leftovers) : '' ) .
																	$excess_txt;
            $excess_txt = '';

            $str =~ s/^[\r\n\s]+//go;

            $y -= $h;
            $total_h += $h;

            redo LOOP;
        }

        last LOOP unless $leftovers;

        $excess_txt = chop($str) . $excess_txt;
        $excess_txt = chop($str) . $excess_txt
            while $str =~ /[\r\n\s]$/o;

        redo LOOP;
    }

    return $total_h;
}

sub calculate
{
    my $self = shift;
    my ($context, $attr) = @_;

    return $self->SUPER::calculate($context, $attr) unless $attr eq 'H';

    return delete $self->{TEMP_H} if exists $self->{TEMP_H};

    my $txt = $self->get_text($context);

    return $self->show_boxed(
        $context, $txt,
        (map { $context->get($self, $_) } qw(X Y W H)),
        'left', 'blind',
    );
}

1;
__END__

=head1 NAME

PDF::Template::Element::TextBox

=head1 PURPOSE

To write text in a specified spot

=head1 NODE NAME

TEXTBOX

=head1 INHERITANCE

PDF::Template::Element

=head1 ATTRIBUTES

=over 4

=item * TEXT
This is the text for this textbox. Can be either as a parameter or as character
children of this node. Defaults to '' (the empty string).

=item * ALIGN / JUSTIFY
This is the orientation of the text in the textbox. Legal values are:

=over 4

=item * Left (default)

=item * Center

=item * Right

=item * Full (NOT IMPLEMENTED)

=back

JUSTIFY is provided for backwards compatibility, and is deprecated.

=item * COLOR
This is the color of the text

=item * BGCOLOR
This is the color of background

=item * BORDER
This is a boolean specifying if a border should be drawn. Currently, the border
is drawn in the same color as the text.

=item * LMARGIN / RMARGIN
These are the paddings within the textbox for the text. This is useful if you
are listing columns of numbers and don't want them to run into one another.

=item * H
Normally, one would not set H, as it should be set by either the FONT or ROW
ancestor. However, it can be useful to do the following:

  <font h="8" face="Times-Roman">

    <row>
      <textbox w="100%" h="*4">Some text here</textbox>
    </row>

  </font>

That will create textbox which will occupy four rows of text at whatever size
the font is set to.

=item * TRUNCATE_TEXT
Normally, at textbox will use as many rows it needs to write the text given to
it. (It will always respect its width requirement, even to the point of
splitting words, though it tries hard to preserve words.) However, sometimes
this behavior is undesirable.

Set this to a true value and the height value will be a requirement, not an
option.

=back

=head1 CHILDREN

None

=head1 AFFECTS

Nothing

=head1 DEPENDENCIES

ROW

=head1 USAGE

  <row h="8">
    <textbox w="40%" text="Some text here"/>
    <textbox w="60%"><var name="Param1"/> and stuff</textbox>
  </row>

This will put two textboxes on the page at the current Y-position. The first
will occupy 40% of the write-able space and contain the text "Some text here".
The second will occupy the rest and contain the text from Param1, then the text
" and stuff". (This is the only way to mix parameters and static text in the
same textbox.)

=head1 AUTHOR

Rob Kinyon (rkinyon@columbus.rr.com)

=head1 SEE ALSO

ROW

=cut
