use strict;
use warnings;
use Test::More tests => 3;

use Sub::Signature;

eval 'sub foo ($bar) { $bar }';
ok(!$@, 'signatures parse in eval');
ok(\&foo, 'sub declared in eval');
is(foo(42), 42, 'eval signature works');
