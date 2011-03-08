# Bug reported by flitman@d902.iki.rssi.ru
# Report against 0.29_01:
#   It looks like conditional in the form <if name="..." is="..."> is
# inverted, i.e. is="true" fires when the variable is actually "false"
# (0, undef), and vice versa.

use strict;
use warnings;

use Test::More tests => 11;

use lib '../../PDF-Writer/trunk/lib';

use_ok( 'PDF::Writer', 'mock' );
my $mock = 'PDF::Writer::mock';
$mock->mock_reset;

my $CLASS = 'PDF::Template';
use_ok( $CLASS );

my $start_pos = tell DATA;

# Case 1: foo is not passed in (should be false)
{
    my $object = $CLASS->new(
        file => \*DATA,
    );
    isa_ok( $object, $CLASS );

    ok( $object->write_file( 'filename' ), 'Something returned from write_file' );

    my $expected = [
        [ 'open', 'filename' ],
        [ 'parameter', 'openaction', 'fitpage', ],
        [ 'parameter', 'openmode', 'none' ],
        [ 'info', 'Creator', 'PDF::Template' ],
        [ 'info', 'Author', 'PDF::Template' ],
        [ 'begin_page', '614.295', '794.97' ],
        [ 'end_page' ],
        [ 'save' ],
    ];

    my @calls = $mock->mock_retrieve;
    print map { "\t$_->[0]\n" } @calls;
    is_deeply( \@calls, $expected, 'Calls match up' );

    $mock->mock_reset;
    seek DATA, $start_pos, 0;
}

# Case 2: foo is passed in, but is false
{
    my $object = $CLASS->new(
        file => \*DATA,
    );
    isa_ok( $object, $CLASS );

    $object->param( foo => 0 );

    ok( $object->write_file( 'filename' ), 'Something returned from write_file' );

    my $expected = [
        [ 'open', 'filename' ],
        [ 'parameter', 'openaction', 'fitpage', ],
        [ 'parameter', 'openmode', 'none' ],
        [ 'info', 'Creator', 'PDF::Template' ],
        [ 'info', 'Author', 'PDF::Template' ],
        [ 'begin_page', '614.295', '794.97' ],
        [ 'end_page' ],
        [ 'save' ],
    ];

    my @calls = $mock->mock_retrieve;
    print map { "\t$_->[0]\n" } @calls;
    is_deeply( \@calls, $expected, 'Calls match up' );

    $mock->mock_reset;
    seek DATA, $start_pos, 0;
}

# Case 3: foo is passed in and is true
{
    my $object = $CLASS->new(
        file => \*DATA,
    );
    isa_ok( $object, $CLASS );

    $object->param( foo => 1 );

    ok( $object->write_file( 'filename' ), 'Something returned from write_file' );

    my $expected = [
        [ 'open', 'filename' ],
        [ 'parameter', 'openaction', 'fitpage', ],
        [ 'parameter', 'openmode', 'none' ],
        [ 'info', 'Creator', 'PDF::Template' ],
        [ 'info', 'Author', 'PDF::Template' ],
        [ 'begin_page', '614.295', '794.97' ],
        [ 'end_page' ],
        [ 'begin_page', '614.295', '794.97' ],
        [ 'end_page' ],
        [ 'save' ],
    ];

    my @calls = $mock->mock_retrieve;
    print map { "\t$_->[0]\n" } @calls;
    is_deeply( \@calls, $expected, 'Calls match up' );

    $mock->mock_reset;
    seek DATA, $start_pos, 0;
}

__DATA__
<pdftemplate>
  <pagedef />
  <if name="foo" is="true">
    <pagedef />
  </if>
</pdftemplate>
