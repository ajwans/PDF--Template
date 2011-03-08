# Bug reported by flitman@d902.iki.rssi.ru
# Report against 0.29_01:
#   parameters "landscape", "pagesize", "page_width",
# "page_height" still do not work. PDF is always generated in
# Letter-portrait mode (at least, I was unable to produce anything else).

use strict;
use warnings;

use Test::More tests => 11;
use IO::Scalar;

use lib '../../PDF-Writer/trunk/lib';

use_ok( 'PDF::Writer', 'mock' );
my $mock = 'PDF::Writer::mock';
$mock->mock_reset;

my $CLASS = 'PDF::Template';
use_ok( $CLASS );

# Case 1: set landscape
{
    my $fh = q{<pdftemplate><pagedef landscape="1"/></pdftemplate>};
    my $object = $CLASS->new(
        file => IO::Scalar->new(\$fh),
    );
    isa_ok( $object, $CLASS );

    ok( $object->write_file( 'filename' ), 'Something returned from write_file' );

    my $expected = [
        [ 'open', 'filename' ],
        [ 'parameter', 'openaction', 'fitpage', ],
        [ 'parameter', 'openmode', 'none' ],
        [ 'info', 'Creator', 'PDF::Template' ],
        [ 'info', 'Author', 'PDF::Template' ],
        [ 'begin_page', '794.97', '614.295' ],
        [ 'end_page' ],
        [ 'save' ],
    ];

    my @calls = $mock->mock_retrieve;
    is_deeply( \@calls, $expected, 'Calls match up' );

    $mock->mock_reset;
}

# Case 2: set page_size to something
{
    my $fh = q{<pdftemplate><pagedef page_height="8p" page_width="10p"/></pdftemplate>};
    my $object = $CLASS->new(
        file => IO::Scalar->new(\$fh),
    );
    isa_ok( $object, $CLASS );

    ok( $object->write_file( 'filename' ), 'Something returned from write_file' );

    my $expected = [
        [ 'open', 'filename' ],
        [ 'parameter', 'openaction', 'fitpage', ],
        [ 'parameter', 'openmode', 'none' ],
        [ 'info', 'Creator', 'PDF::Template' ],
        [ 'info', 'Author', 'PDF::Template' ],
        [ 'begin_page', '10', '8' ],
        [ 'end_page' ],
        [ 'save' ],
    ];

    my @calls = $mock->mock_retrieve;
    is_deeply( \@calls, $expected, 'Calls match up' );

    $mock->mock_reset;
}

# Case 3: set page_height and page_width
{
    my $fh = q{<pdftemplate><pagedef pagesize="Legal"/></pdftemplate>};
    my $object = $CLASS->new(
        file => IO::Scalar->new(\$fh),
    );
    isa_ok( $object, $CLASS );

    ok( $object->write_file( 'filename' ), 'Something returned from write_file' );

    my $expected = [
        [ 'open', 'filename' ],
        [ 'parameter', 'openaction', 'fitpage', ],
        [ 'parameter', 'openmode', 'none' ],
        [ 'info', 'Creator', 'PDF::Template' ],
        [ 'info', 'Author', 'PDF::Template' ],
        [ 'begin_page', '614.295', '1011.78' ],
        [ 'end_page' ],
        [ 'save' ],
    ];

    my @calls = $mock->mock_retrieve;
    is_deeply( \@calls, $expected, 'Calls match up' );

    $mock->mock_reset;
}
