use strict;
use warnings;
use Test::More tests => 1;

use Sub::Signature;

my $foo = sub ($bar, $baz) { return "${bar}-${baz}" };

is($foo->(qw/bar baz/), 'bar-baz');
