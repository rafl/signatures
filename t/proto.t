use strict;
use warnings;
use Test::More tests => 3;

use Sub::Signature;

sub with_proto ($x, $y, $z) : proto($$$) {
    return $x + $y + $z;
}

{
    my $foo;
    sub with_lvalue () : lvalue proto() { $foo }
}

is(prototype('with_proto'), '$$$', ':proto attribute');

is(prototype('with_lvalue'), '', ':proto with other attributes');
with_lvalue = 1;
is(with_lvalue, 1, 'other attributes still there');
