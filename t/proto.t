use strict;
use warnings;
use Test::More tests => 1;

use Sub::Signature;

sub with_proto ($x, $y, $z) : proto($$$) {
    return $x + $y + $z;
}

is(prototype('with_proto'), '$$$', ':proto attribute');
