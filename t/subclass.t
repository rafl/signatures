use strict;
use warnings;
use Test::More tests => 1;

{
    package CustomSignature;

    use parent qw/Sub::Signature/;

    use Sub::Signature;

    sub proto_unwrap ($class, $prototype) {
        return "my (\$prototype) = '$prototype';";
    }
}

BEGIN { CustomSignature->import }

sub foo (aieee) { $prototype }

is(foo(), 'aieee', 'overriding proto_unwrap');
