use strict;
use warnings;

use Test::More tests => 8;

use_ok( 'PDF::Writer', 'mock' );

my $CLASS = 'PDF::Template';
use_ok( $CLASS )
    or Test::More->builder->BAILOUT( "Cannot load $CLASS" );

# Test plan:
# 1) Verify that the API is correct. This will serve as documentation for which methods
#    should be part of which kind of API.
# 2) Verify that all methods in $CLASS have been classified appropriately

my %existing_methods = do {
    no strict 'refs';
    map {
        $_ => undef
    } grep {
        /^[a-zA-Z_]+$/
    } grep {
        exists &{${ $CLASS . '::'}{$_}}
    } keys %{ $CLASS . '::'}
};

my %methods = (
    class => [ qw(
        new
    )],
    public => [ qw(
        param write_file output get_buffer parse parse_xml register
    )],
    private => [ qw(
        _prepare_output
    )],
#    book_keeping => [qw(
#    )],
    imported => [qw(
        fileparse
    )],
);

# These are the class methods
can_ok( $CLASS, @{ $methods{class} } );
delete @existing_methods{@{$methods{class}}};

my $tree = $CLASS->new();
isa_ok( $tree, $CLASS );

for my $type ( qw( public private imported ) ) {
    can_ok( $tree, @{ $methods{ $type } } );
    delete @existing_methods{@{$methods{ $type }}};
}

if ( my @k = keys %existing_methods ) {
    ok( 0, "We need to account for '" . join ("','", @k) . "'" );
}
else {
    ok( 1, "We've accounted for everything." );
}
