use strict;
use warnings;

use Test::More tests => 18;

use File::Spec::Functions qw( catfile );

use lib '../../PDF-Writer/trunk/lib';

use_ok( 'PDF::Writer', 'mock' );
my $mock = 'PDF::Writer::mock';
$mock->mock_reset;

my $CLASS = 'PDF::Template';
use_ok( $CLASS );

my $start_pos = tell DATA;

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
    is_deeply( \@calls, $expected, 'Calls match up' );

    $mock->mock_reset;
    seek DATA, $start_pos, 0;
}

{
    my $object = $CLASS->new();
    isa_ok( $object, $CLASS );

    ok( $object->parse( \*DATA ), "parse() called explicitly" );

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
    is_deeply( \@calls, $expected, 'Calls match up' );

    $mock->mock_reset;
    seek DATA, $start_pos, 0;
}

{
    my $object = $CLASS->new(
        file => \*DATA,
    );
    isa_ok( $object, $CLASS );

    ok( $object->get_buffer(), 'Something returned from get_buffer' );

    my $expected = [
        [ 'open' ],
        [ 'parameter', 'openaction', 'fitpage', ],
        [ 'parameter', 'openmode', 'none' ],
        [ 'info', 'Creator', 'PDF::Template' ],
        [ 'info', 'Author', 'PDF::Template' ],
        [ 'begin_page', '614.295', '794.97' ],
        [ 'end_page' ],
        [ 'stringify' ],
    ];

    my @calls = $mock->mock_retrieve;
    is_deeply( \@calls, $expected, 'Calls match up' );

    $mock->mock_reset;
    seek DATA, $start_pos, 0;
}

{
    my $object = $CLASS->new(
        filename => \*DATA,
    );
    isa_ok( $object, $CLASS );

    ok( $object->output(), 'Something returned from output' );

    my $expected = [
        [ 'open' ],
        [ 'parameter', 'openaction', 'fitpage', ],
        [ 'parameter', 'openmode', 'none' ],
        [ 'info', 'Creator', 'PDF::Template' ],
        [ 'info', 'Author', 'PDF::Template' ],
        [ 'begin_page', '614.295', '794.97' ],
        [ 'end_page' ],
        [ 'stringify' ],
    ];

    my @calls = $mock->mock_retrieve;
    is_deeply( \@calls, $expected, 'Calls match up' );

    $mock->mock_reset;
    seek DATA, $start_pos, 0;
}

{
    my $object = $CLASS->new(
        file => catfile( qw( t templates 001.tmpl ) ),
        openaction => 'fitheight',
        openmode => 'bookmarks',
        info => {
            Author => 'Fred Flintstone',
        },
    );
    isa_ok( $object, $CLASS );

    ok( $object->output(), 'Something returned from output' );

    my $expected = [
        [ 'open' ],
        [ 'parameter', 'openaction', 'fitheight', ],
        [ 'parameter', 'openmode', 'bookmarks' ],
        [ 'info', 'Author', 'Fred Flintstone' ],
        [ 'begin_page', '614.295', '794.97' ],
        [ 'end_page' ],
        [ 'stringify' ],
    ];

    my @calls = $mock->mock_retrieve;
    is_deeply( \@calls, $expected, 'Calls match up' );

    $mock->mock_reset;
}

__DATA__
<pdftemplate>
  <pagedef />
</pdftemplate>
