use strict;
use warnings;
use Test::More tests => 4;

use vars qw/@warnings/;

BEGIN { $SIG{__WARN__} = sub { push @warnings, $_ } }

{
    use Sub::Signature;
    sub foo ($x) { }
}

BEGIN { is(@warnings, 0, 'no prototype warnings with Sub::Signature in scope') }

sub bar ($x) { }

BEGIN { is(@warnings, 1, 'warning without Sub::Signature in scope') }

use Sub::Signature;

sub baz ($x) { }

BEGIN { is(@warnings, 1, 'no more warnings') }

no Sub::Signature;

sub corge ($x) { }

BEGIN { is(@warnings, 2, 'disabling magic with unimport') }
